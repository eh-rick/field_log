import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  static const String _baseUrl = 'https://6a3d8a7dd8e212699e23fa6d.mockapi.io/v1';

  Future<bool> uploadSighting({
    required Map<String, dynamic> sightingData,
    required List<String> localPhotoPaths,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/sightings');
      final request = http.MultipartRequest('POST', url);

      request.fields['uuid'] = sightingData['uuid']?.toString() ?? '';
      request.fields['user_uuid'] = sightingData['user_uuid']?.toString() ?? '';
      request.fields['species_name'] = sightingData['species_name']?.toString() ?? '';
      request.fields['latitude'] = sightingData['latitude']?.toString() ?? '0.0';
      request.fields['longitude'] = sightingData['longitude']?.toString() ?? '0.0';
      request.fields['animal_count'] = sightingData['animal_count']?.toString() ?? '0';
      request.fields['notes'] = sightingData['notes']?.toString() ?? '';
      request.fields['created'] = sightingData['created']?.toString() ?? '';

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