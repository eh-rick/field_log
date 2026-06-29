import 'package:field_log/controllers/base_controller.dart';
import 'package:field_log/data_models/sighting.dart';
import 'package:field_log/services/image_picker_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../services/database_service.dart';
import '../services/database_schema.dart';
import '../services/encryption_service.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';    
import 'dashboard_controller.dart';

class LogFormController extends BaseController {
  final _dbService = DatabaseService();
  final _mediaService = ImagePickerService();
  final _encryptionService = EncryptionService();
  final _apiService = ApiService();
  final _connectivityService = ConnectivityService();
  final _locationService = LocationService();  

  bool _isSaving = false;
  String _locationError = '';                   
  final List<String> _capturedPhotoPaths = [];

  bool get isSaving => _isSaving;
  String get locationError => _locationError;  
  List<String> get capturedPhotoPaths => _capturedPhotoPaths;


  Future<void> takePhoto() async {
    final path = await _mediaService.captureCompressedPhoto();
    if (path != null) {
      _capturedPhotoPaths.add(path);
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    _mediaService.deleteLocalPhoto(_capturedPhotoPaths[index]);
    _capturedPhotoPaths.removeAt(index);
    notifyListeners();
  }
 
  Future<bool> saveSighting({
    required String species,
    required int count,
    required String notes,
  }) async {
    _isSaving = true;
    _locationError = ''; 
    notifyListeners();
    String syncStatus = 'pending'; 
    try {
      final Position position = await _locationService.getCurrentLocation();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userUuid = prefs.getString('current_user_uuid') ?? generateUuid();
      final sightingUuid = generateUuid();
      final timestamp = DateTime.now().toIso8601String();
    
      final SightingModel sighting = SightingModel(
        uuid: sightingUuid,
        userUuid: userUuid,
        speciesName: species,
        latitude: position.latitude,
        longitude: position.longitude,
        animalCount: count,
        notes: notes,
        syncStatus: syncStatus,
        created: timestamp,
      );
      final bool isOnline = await _connectivityService.isConnected;
      if (isOnline) {
        final bool uploadSuccess = await _apiService.uploadSighting(
          sighting: sighting,
          localPhotoPaths: _capturedPhotoPaths,
        );
        if (uploadSuccess) {
          syncStatus = 'synced';
        }
      }
      final encryptedSpecies = _encryptionService.encryptText(species, sightingUuid);
      final encryptedNotes = notes.isNotEmpty 
          ? _encryptionService.encryptText(notes, sightingUuid) 
          : '';

      final db = await _dbService.database;
      await db.transaction((txn) async {
        await txn.insert(DatabaseSchema.tableSightings, {
          DatabaseSchema.colUuid: sightingUuid,
          DatabaseSchema.colUserId: userUuid,
          DatabaseSchema.colSpeciesName: encryptedSpecies,
          DatabaseSchema.colLatitude: position.latitude,   
          DatabaseSchema.colLongitude: position.longitude, 
          DatabaseSchema.colAnimalCount: count,
          DatabaseSchema.colNotes: encryptedNotes,
          DatabaseSchema.colSyncStatus: syncStatus,
          DatabaseSchema.colCreated: timestamp,
          DatabaseSchema.colLastModified: timestamp,
        });

        for (final photoPath in _capturedPhotoPaths) {
          await txn.insert(DatabaseSchema.tablePhotos, {
            DatabaseSchema.colUuid: generateUuid(),
            DatabaseSchema.colSightingId: sightingUuid,
            DatabaseSchema.colLocalFilePath: photoPath,
          });
        }

        await txn.insert(DatabaseSchema.tableAuditTrail, {
          DatabaseSchema.colUuid: generateUuid(),
          DatabaseSchema.colAction: 'INSERT',
          DatabaseSchema.colTableName: DatabaseSchema.tableSightings,
          DatabaseSchema.colRecordUuid: sightingUuid,
          DatabaseSchema.colUserId: userUuid,
          DatabaseSchema.colCreated: timestamp,
        });
      });

      _capturedPhotoPaths.clear();
      _isSaving = false;
      notifyListeners();
      await DashboardController().loadSightings();
      return true;
    } catch (e) {
      _isSaving = false;
      _locationError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

}