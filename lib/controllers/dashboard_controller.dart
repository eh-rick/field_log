import 'package:field_log/data_models/sighting.dart';
import 'package:field_log/services/database_schema.dart';
import 'package:field_log/services/encryption_service.dart';
import 'package:field_log/services/export_service.dart';
import 'package:field_log/services/share_service.dart';
import 'package:field_log/services/sync_service.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';

class DashboardController extends ChangeNotifier {
  static final DashboardController _instance = DashboardController._internal();
  factory DashboardController() => _instance;
  DashboardController._internal();

  final DatabaseService _dbService = DatabaseService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final EncryptionService _encryptionService = EncryptionService();
  final ExportService _exportService = ExportService();
  final ShareService _shareService = ShareService();

  List<SightingModel> _sightings = [];
  List<SightingModel> get sightings => _sightings;

  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isOnline = false;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  int get pendingCount => _sightings.where( (s) => s.syncStatus == 'pending').length;
  bool _isExporting = false;
  bool get isExporting => _isExporting;


  Future<bool> handleExportAndShare() async {
    final String? csvFilePath = await triggerCsvExport();
    if( csvFilePath == null ){
      return false;
    }
    try {
      await _shareService.shareFile(csvFilePath);
      return true;
    } catch ( e ) {
      debugPrint( e.toString() );
    }
    return false;
  }

Future<void> loadSightings() async {
  _isLoading = true;
  notifyListeners();

  final db = await _dbService.database;
  final List<Map<String, dynamic>> rawMaps = await db.query( DatabaseSchema.tableSightings );
  _sightings = rawMaps.map( ( map ) => SightingModel.fromEncryptedMap( map, _encryptionService ) ).toList();
  _isLoading = false;
  notifyListeners();
}

  Future<String?> triggerCsvExport() async {
    if ( _sightings.isEmpty ) return null;
    _isExporting = true;
    notifyListeners();
    final String savedPath = await _exportService.exportSightingsToCSV( _sightings );
    if( savedPath.isEmpty ){
      return null;
    }
    return savedPath;
  }

  Future<void> syncPendingSightings() async {
    await SyncService().triggerBackgroundSync();
    await loadSightings();
  }


  void init() {
    _connectivityService.onConnectivityChanged.listen((connected) {
      _isOnline = connected;
      notifyListeners();
    } );
    _checkCurrentConnectivity();
    loadSightings();
  }

  Future<void> _checkCurrentConnectivity() async {
    _isOnline = await _connectivityService.isConnected;
    notifyListeners();
  }
}
