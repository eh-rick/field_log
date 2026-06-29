import 'dart:io';
import 'package:field_log/data_models/sighting.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  static const String _baseUrl = 'https://6a3d8a7dd8e212699e23fa6d.mockapi.io/v1/';

  Future<bool> uploadSighting({
    required SightingModel sighting,
    required List<String> localPhotoPaths,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/sightings');
      final request = http.MultipartRequest('POST', url);
      
      request.fields['uuid'] = sighting.uuid;
      request.fields['user_uuid'] = sighting.userUuid;
      request.fields['species_name'] = sighting.speciesName;
      request.fields['latitude'] = sighting.latitude.toString();
      request.fields['longitude'] = sighting.longitude.toString();
      request.fields['animal_count'] = sighting.animalCount.toString();
      request.fields['notes'] = sighting.notes;
      request.fields['created'] = sighting.created;
      request.fields['images'] = sighting.created;

      for (final filePath in localPhotoPaths) {
        final file = File(filePath);
        if (await file.exists()) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            'photos', 
            stream,
            length,
            filename: Uri.file(filePath).pathSegments.last,
          );
          request.files.add(multipartFile);
        }
      }
      
      print('Firing payload to MockAPI: $url');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('MockAPI Accepted Data [${response.statusCode}]: ${response.body}');
        return true;
      } else {
        print('MockAPI Rejected Request [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network pipeline error: $e');
      return false;
    }
  }
}