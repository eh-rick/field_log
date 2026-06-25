// import 'dart:async';
// import 'connectivity_service.dart';
// import 'database_service.dart';
// import '../services/database_schema.dart';
// import '../controllers/dashboard_controller.dart'; // 1. ADD THIS IMPORT

// class SyncService {
//   static final SyncService _instance = SyncService._internal();
//   factory SyncService() => _instance;
//   SyncService._internal();

//   final _connectivityService = ConnectivityService();
//   final _dbService = DatabaseService();
//   StreamSubscription<bool>? _connectivitySubscription;
//   bool _isSyncing = false;

//   void initialize() {
//     if (_connectivitySubscription != null) return;

//     _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
//       if (isOnline) {
//         print('Network connection restored. Triggering automatic sync engine...');
//         triggerBackgroundSync();
//       }
//     });
//   }

//   Future<void> triggerBackgroundSync() async {
//     if (_isSyncing) return;
//     if (!await _connectivityService.isConnected) return;

//     _isSyncing = true;

//     try {
//       final db = await _dbService.database;
      
//       final List<Map<String, dynamic>> pendingSightings = await db.query(
//         DatabaseSchema.tableSightings,
//         where: '${DatabaseSchema.colSyncStatus} = ?',
//         whereArgs: ['pending'],
//       );

//       if (pendingSightings.isEmpty) {
//         _isSyncing = false;
//         return;
//       }

//       print('Processing ${pendingSightings.length} pending records...');

//       for (final sighting in pendingSightings) {
//         final uuid = sighting[DatabaseSchema.colUuid];
//         bool networkUploadSuccess = true; // Your network layer placeholder

//         if (networkUploadSuccess) {
//           await db.update(
//             DatabaseSchema.tableSightings,
//             {DatabaseSchema.colSyncStatus: 'synced'},
//             where: '${DatabaseSchema.colUuid} = ?',
//             whereArgs: [uuid],
//           );
//         }
//       }
      
//       print('Background synchronization batch processing finished.');
      
//       // 2. CORE FIX: Force the active UI controller snapshot to reload from SQLite disk
//       await DashboardController().loadSightings();

//     } catch (e) {
//       print('Sync Engine process suspended: $e');
//     } finally {
//       _isSyncing = false;
//     }
//   }

//   void dispose() {
//     _connectivitySubscription?.cancel();
//     _connectivitySubscription = null;
//   }
// }

import 'dart:async';
import 'connectivity_service.dart';
import 'database_service.dart';
import 'api_service.dart';
import 'encryption_service.dart';
import '../services/database_schema.dart';
import '../controllers/dashboard_controller.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _connectivityService = ConnectivityService();
  final _dbService = DatabaseService();
  final _apiService = ApiService();
  final _encryptionService = EncryptionService();
  
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Initializes the global sync observer loop. Called once at app boot.
  void initialize() {
    if (_connectivitySubscription != null) return;

    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        print('[Sync Engine] Internet connection detected. Launching sync sweep...');
        triggerBackgroundSync();
      }
    });
  }

  Future<void> triggerBackgroundSync() async {
    if (_isSyncing) return;
    if (!await _connectivityService.isConnected) return;

    _isSyncing = true;

    try {
      final db = await _dbService.database;
      
      final List<Map<String, dynamic>> pendingSightings = await db.query(
        DatabaseSchema.tableSightings,
        where: '${DatabaseSchema.colSyncStatus} = ?',
        whereArgs: ['pending'],
      );

      if (pendingSightings.isEmpty) {
        print('[Sync Engine] Scan complete. Zero pending records found.');
        _isSyncing = false;
        return;
      }

      print('[Sync Engine] Processing ${pendingSightings.length} pending entries...');

      for (final sighting in pendingSightings) {
        final String sightingUuid = sighting[DatabaseSchema.colUuid] as String;

        final List<Map<String, dynamic>> photoRecords = await db.query(
          DatabaseSchema.tablePhotos,
          where: '${DatabaseSchema.colSightingId} = ?',
          whereArgs: [sightingUuid],
        );

        final List<String> localPhotoPaths = photoRecords
            .map((p) => p[DatabaseSchema.colLocalFilePath] as String)
            .toList();

        String decryptedSpecies = '';
        try {
          decryptedSpecies = _encryptionService.decryptText(
            sighting[DatabaseSchema.colSpeciesName] as String, 
            sightingUuid,
          );
        } catch (_) {
          decryptedSpecies = sighting[DatabaseSchema.colSpeciesName] as String;
        }
        
        String decryptedNotes = '';
        final String? rawNotes = sighting[DatabaseSchema.colNotes] as String?;
        if (rawNotes != null && rawNotes.isNotEmpty) {
          try {
            decryptedNotes = _encryptionService.decryptText(rawNotes, sightingUuid);
          } catch (_) {
            decryptedNotes = rawNotes;
          }
        }

        final Map<String, dynamic> clearPayload = {
          'uuid': sightingUuid,
          'user_uuid': sighting[DatabaseSchema.colUserId],
          'species_name': decryptedSpecies,
          'latitude': sighting[DatabaseSchema.colLatitude],
          'longitude': sighting[DatabaseSchema.colLongitude],
          'animal_count': sighting[DatabaseSchema.colAnimalCount],
          'notes': decryptedNotes,
          'created': sighting[DatabaseSchema.colCreated],
          'photos': localPhotoPaths,
        };

        final bool uploadSuccess = await _apiService.uploadSighting(
          sightingData: clearPayload,
          localPhotoPaths: localPhotoPaths,
        );

        if (uploadSuccess) {
          await db.update(
            DatabaseSchema.tableSightings,
            {DatabaseSchema.colSyncStatus: 'synced'},
            where: '${DatabaseSchema.colUuid} = ?',
            whereArgs: [sightingUuid],
          );
          print('[Sync Engine] Record $sightingUuid successfully migrated to cloud.');
        } else {
          print('[Sync Engine] Push failed for record $sightingUuid. Retaining local backup.');
        }
      }
      
      print('[Sync Engine] Processing sequence completed.');
      await DashboardController().loadSightings();

    } catch (e) {
      print('[Sync Engine] Unexpected crash encountered during synchronization: $e');
    } finally {
      _isSyncing = false;
    }
  }
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}