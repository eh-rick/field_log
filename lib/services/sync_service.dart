import 'dart:async';
import 'package:field_log/data_models/sighting.dart';

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

      for (final sightingMap in pendingSightings) {
        final String sightingUuid = sightingMap[DatabaseSchema.colUuid] as String;

        final List<Map<String, dynamic>> photoRecords = await db.query(
          DatabaseSchema.tablePhotos,
          where: '${DatabaseSchema.colSightingId} = ?',
          whereArgs: [sightingUuid],
        );

        final List<String> localPhotoPaths = photoRecords
            .map((p) => p[DatabaseSchema.colLocalFilePath] as String)
            .toList();

        final SightingModel sighting = SightingModel.fromEncryptedMap(
          sightingMap, 
          _encryptionService,
        );

        final bool uploadSuccess = await _apiService.uploadSighting(
          sighting: sighting,
          localPhotoPaths: localPhotoPaths,
        );

        if (uploadSuccess) {
          await db.update(
            DatabaseSchema.tableSightings,
            {DatabaseSchema.colSyncStatus: 'synced'},
            where: '${DatabaseSchema.colUuid} = ?',
            whereArgs: [sightingUuid],
          );
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