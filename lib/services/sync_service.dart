import 'dart:async';
import 'connectivity_service.dart';
import 'database_service.dart';
import '../services/database_schema.dart';
import '../controllers/dashboard_controller.dart'; // 1. ADD THIS IMPORT

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _connectivityService = ConnectivityService();
  final _dbService = DatabaseService();
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  void initialize() {
    if (_connectivitySubscription != null) return;

    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        print('Network connection restored. Triggering automatic sync engine...');
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
        _isSyncing = false;
        return;
      }

      print('Processing ${pendingSightings.length} pending records...');

      for (final sighting in pendingSightings) {
        final uuid = sighting[DatabaseSchema.colUuid];
        bool networkUploadSuccess = true; // Your network layer placeholder

        if (networkUploadSuccess) {
          await db.update(
            DatabaseSchema.tableSightings,
            {DatabaseSchema.colSyncStatus: 'synced'},
            where: '${DatabaseSchema.colUuid} = ?',
            whereArgs: [uuid],
          );
        }
      }
      
      print('Background synchronization batch processing finished.');
      
      // 2. CORE FIX: Force the active UI controller snapshot to reload from SQLite disk
      await DashboardController().loadSightings();

    } catch (e) {
      print('Sync Engine process suspended: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}