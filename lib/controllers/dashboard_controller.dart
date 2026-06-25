import 'package:field_log/services/sync_service.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/database_schema.dart';
import '../services/connectivity_service.dart';

class DashboardController extends ChangeNotifier {
  static final DashboardController _instance = DashboardController._internal();
  factory DashboardController() => _instance;
  DashboardController._internal();

  final _dbService = DatabaseService();
  final _connectivityService = ConnectivityService();

  List<Map<String, dynamic>> _sightings = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isOnline = false;

  List<Map<String, dynamic>> get sightings => _sightings;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;

  int get pendingCount => _sightings.where((s) => s[DatabaseSchema.colSyncStatus] == 'pending').length;


Future<void> syncPendingSightings() async {
  await SyncService().triggerBackgroundSync();
  await loadSightings();
}


  void init() {
    _connectivityService.onConnectivityChanged.listen((connected) {
      _isOnline = connected;
      notifyListeners();
    });
    _checkCurrentConnectivity();
    loadSightings();
  }

  Future<void> _checkCurrentConnectivity() async {
    _isOnline = await _connectivityService.isConnected;
    notifyListeners();
  }

  Future<void> loadSightings() async {
    _isLoading = true;
    notifyListeners();

    final db = await _dbService.database;
    _sightings = await db.query(
      DatabaseSchema.tableSightings,
      orderBy: '${DatabaseSchema.colCreated} DESC',
    );

    _isLoading = false;
    notifyListeners();
  }

}