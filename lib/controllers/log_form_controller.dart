// import 'dart:math';
// import 'package:field_log/services/image_picker_service.dart';
// import 'package:field_log/services/location_service.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/database_service.dart';
// import '../services/database_schema.dart';
// import '../services/encryption_service.dart';

// class LogFormController extends ChangeNotifier {
//   final _dbService = DatabaseService();
//   final _mediaService = ImagePickerService();
//   final _encryptionService = EncryptionService();
//   final _locationService = LocationService();

//     String get locationError => _locationError;


//   bool _isSaving = false;
//   final List<String> _capturedPhotoPaths = [];
//   String _locationError = '';


//   bool get isSaving => _isSaving;
//   List<String> get capturedPhotoPaths => _capturedPhotoPaths;

  

//   String _generateUuid() {
//     final random = Random.secure();
//     final values = List<int>.generate(16, (i) => random.nextInt(256));
//     values[6] = (values[6] & 0x0f) | 0x40;
//     values[8] = (values[8] & 0x3f) | 0x80;
    
//     final buffer = StringBuffer();
//     for (var i = 0; i < values.length; i++) {
//       if (i == 4 || i == 6 || i == 8 || i == 10) buffer.write('-');
//       buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
//     }
//     return buffer.toString();
//   }

//   Future<void> takePhoto() async {
//     final path = await _mediaService.captureCompressedPhoto();
//     if (path != null) {
//       _capturedPhotoPaths.add(path);
//       notifyListeners();
//     }
//   }

//   void removePhoto(int index) {
//     _mediaService.deleteLocalPhoto(_capturedPhotoPaths[index]);
//     _capturedPhotoPaths.removeAt(index);
//     notifyListeners();
//   }




//   Future<bool> saveSighting({
//     required String species,
//     required int count,
//     required String notes,
//   }) async {
//     _isSaving = true;
//     _locationError = '';
//     notifyListeners();

//     try {
//       // Fetch device hardware coordinates directly
//       final Position position = await _locationService.getCurrentLocation();
      
//       final db = await _dbService.database;
//       final sightingUuid = _generateUuid();
//       final userUuid = 'default-ranger-uuid-1234567890';
//       final timestamp = DateTime.now().toIso8601String();

//       final encryptedSpecies = _encryptionService.encryptText(species, sightingUuid);
//       final encryptedNotes = notes.isNotEmpty 
//           ? _encryptionService.encryptText(notes, sightingUuid) 
//           : '';

//       await db.transaction((txn) async {
//         await txn.insert(DatabaseSchema.tableSightings, {
//           DatabaseSchema.colUuid: sightingUuid,
//           DatabaseSchema.colUserId: userUuid,
//           DatabaseSchema.colSpeciesName: encryptedSpecies,
//           DatabaseSchema.colLatitude: position.latitude,    // Live latitude
//           DatabaseSchema.colLongitude: position.longitude,  // Live longitude
//           DatabaseSchema.colAnimalCount: count,
//           DatabaseSchema.colNotes: encryptedNotes,
//           DatabaseSchema.colSyncStatus: 'pending',
//           DatabaseSchema.colCreated: timestamp,
//           DatabaseSchema.colLastModified: timestamp,
//         });

//         for (final photoPath in _capturedPhotoPaths) {
//           await txn.insert(DatabaseSchema.tablePhotos, {
//             DatabaseSchema.colUuid: _generateUuid(),
//             DatabaseSchema.colSightingId: sightingUuid,
//             DatabaseSchema.colLocalFilePath: photoPath,
//           });
//         }

//         // ... keep Audit Trail tracking identical
//       });

//       _capturedPhotoPaths.clear();
//       _isSaving = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _isSaving = false;
//       _locationError = e.toString().replaceAll('Exception: ', '');
//       notifyListeners();
//       return false;
//     }
//   }


//   // Future<bool> saveSighting({
//   //   required String species,
//   //   required int count,
//   //   required String notes,
//   //   required double latitude,
//   //   required double longitude,
//   // }) async {
//   //   _isSaving = true;
//   //   notifyListeners();

//   //   try {
//   //     final db = await _dbService.database;
//   //     final sightingUuid = _generateUuid();
//   //     final userUuid = 'default-ranger-uuid-1234567890';
//   //     final timestamp = DateTime.now().toIso8601String();

//   //     final encryptedSpecies = _encryptionService.encryptText(species, sightingUuid);
//   //     final encryptedNotes = notes.isNotEmpty 
//   //         ? _encryptionService.encryptText(notes, sightingUuid) 
//   //         : '';

//   //     await db.transaction((txn) async {
//   //       await txn.insert(DatabaseSchema.tableSightings, {
//   //         DatabaseSchema.colUuid: sightingUuid,
//   //         DatabaseSchema.colUserId: userUuid,
//   //         DatabaseSchema.colSpeciesName: encryptedSpecies,
//   //         DatabaseSchema.colLatitude: latitude,
//   //         DatabaseSchema.colLongitude: longitude,
//   //         DatabaseSchema.colAnimalCount: count,
//   //         DatabaseSchema.colNotes: encryptedNotes,
//   //         DatabaseSchema.colSyncStatus: 'pending',
//   //         DatabaseSchema.colCreated: timestamp,
//   //         DatabaseSchema.colLastModified: timestamp,
//   //       });

//   //       for (final photoPath in _capturedPhotoPaths) {
//   //         await txn.insert(DatabaseSchema.tablePhotos, {
//   //           DatabaseSchema.colUuid: _generateUuid(),
//   //           DatabaseSchema.colSightingId: sightingUuid,
//   //           DatabaseSchema.colLocalFilePath: photoPath,
//   //         });
//   //       }

//   //       await txn.insert(DatabaseSchema.tableAuditTrail, {
//   //         DatabaseSchema.colUuid: _generateUuid(),
//   //         DatabaseSchema.colAction: 'INSERT',
//   //         DatabaseSchema.colTableName: DatabaseSchema.tableSightings,
//   //         DatabaseSchema.colRecordUuid: sightingUuid,
//   //         DatabaseSchema.colUserId: userUuid,
//   //         DatabaseSchema.colCreated: timestamp,
//   //       });
//   //     });

//   //     _capturedPhotoPaths.clear();
//   //     _isSaving = false;
//   //     notifyListeners();
//   //     return true;
//   //   } catch (_) {
//   //     _isSaving = false;
//   //     notifyListeners();
//   //     return false;
//   //   }
//   // }


// }

// // import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import '../services/location_service.dart';
// // // ... keep other imports identical

// // class LogFormController extends ChangeNotifier {
// //   final _dbService = DatabaseService();
// //   final _mediaService = MediaService();
// //   final _encryptionService = EncryptionService();
// //   final _locationService = LocationService(); // Instantiate location service

// //   bool _isSaving = false;
// //   String _locationError = '';
// //   final List<String> _capturedPhotoPaths = [];

// //   bool get isSaving => _isSaving;
// //   String get locationError => _locationError;
// //   List<String> get capturedPhotoPaths => _capturedPhotoPaths;

// //   // ... keep _generateUuid, takePhoto, removePhoto identical

// //   Future<bool> saveSighting({
// //     required String species,
// //     required int count,
// //     required String notes,
// //   }) async {
// //     _isSaving = true;
// //     _locationError = '';
// //     notifyListeners();

// //     try {
// //       // Fetch device hardware coordinates directly
// //       final Position position = await _locationService.getCurrentLocation();
      
// //       final db = await _dbService.database;
// //       final sightingUuid = _generateUuid();
// //       final userUuid = 'default-ranger-uuid-1234567890';
// //       final timestamp = DateTime.now().toIso8601String();

// //       final encryptedSpecies = _encryptionService.encryptText(species, sightingUuid);
// //       final encryptedNotes = notes.isNotEmpty 
// //           ? _encryptionService.encryptText(notes, sightingUuid) 
// //           : '';

// //       await db.transaction((txn) async {
// //         await txn.insert(DatabaseSchema.tableSightings, {
// //           DatabaseSchema.colUuid: sightingUuid,
// //           DatabaseSchema.colUserId: userUuid,
// //           DatabaseSchema.colSpeciesName: encryptedSpecies,
// //           DatabaseSchema.colLatitude: position.latitude,    // Live latitude
// //           DatabaseSchema.colLongitude: position.longitude,  // Live longitude
// //           DatabaseSchema.colAnimalCount: count,
// //           DatabaseSchema.colNotes: encryptedNotes,
// //           DatabaseSchema.colSyncStatus: 'pending',
// //           DatabaseSchema.colCreated: timestamp,
// //           DatabaseSchema.colLastModified: timestamp,
// //         });

// //         for (final photoPath in _capturedPhotoPaths) {
// //           await txn.insert(DatabaseSchema.tablePhotos, {
// //             DatabaseSchema.colUuid: _generateUuid(),
// //             DatabaseSchema.colSightingId: sightingUuid,
// //             DatabaseSchema.colLocalFilePath: photoPath,
// //           });
// //         }

// //         // ... keep Audit Trail tracking identical
// //       });

// //       _capturedPhotoPaths.clear();
// //       _isSaving = false;
// //       notifyListeners();
// //       return true;
// //     } catch (e) {
// //       _isSaving = false;
// //       _locationError = e.toString().replaceAll('Exception: ', '');
// //       notifyListeners();
// //       return false;
// //     }
// //   }


// // }

import 'dart:io';
import 'dart:math';
import 'package:field_log/services/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import '../services/database_service.dart';
import '../services/database_schema.dart';
import '../services/encryption_service.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';    
import 'dashboard_controller.dart';

class LogFormController extends ChangeNotifier {
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

  String _generateUuid() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    
    final buffer = StringBuffer();
    for (var i = 0; i < values.length; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) buffer.write('-');
      buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

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
      
      final sightingUuid = _generateUuid();
      final userUuid = 'default-ranger-uuid-1234567890';
      final timestamp = DateTime.now().toIso8601String();

      final Map<String, dynamic> clearPayload = {
        'uuid': sightingUuid,
        'user_uuid': userUuid,
        'species_name': species,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'animal_count': count,
        'notes': notes,
        'created': timestamp,
      };

      final bool isOnline = await _connectivityService.isConnected;

      if (isOnline) {
        final uploadSuccess = await _apiService.uploadSighting(
          sightingData: clearPayload,
          localPhotoPaths: _capturedPhotoPaths,
        );

        if (uploadSuccess) {
          syncStatus = 'synced';
          print('[LogForm] Immediate upload cleared! Storing log status as "synced".');
        } else {
          print('[LogForm] API rejected upload or timed out. Falling back to "pending".');
        }
      } else {
        print('[LogForm] Device offline. Marking as "pending" for SyncEngine.');
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
        } );

        for (final photoPath in _capturedPhotoPaths) {

          await txn.insert(DatabaseSchema.tablePhotos, {
            DatabaseSchema.colUuid: _generateUuid(),
            DatabaseSchema.colSightingId: sightingUuid,
            DatabaseSchema.colLocalFilePath: photoPath,
          });

        }

        await txn.insert(DatabaseSchema.tableAuditTrail, {
          DatabaseSchema.colUuid: _generateUuid(),
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