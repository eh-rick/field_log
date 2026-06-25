import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<String?> captureCompressedPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 720,
      imageQuality: 80,
    );
    if (photo == null) return null;
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String photosDirPath = p.join(appDir.path, 'sighting_photos');
    final Directory photosDir = Directory(photosDirPath);

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String targetPath = p.join(photosDirPath, fileName);

    final File savedFile = await File(photo.path).copy(targetPath);
    return savedFile.path;
  }

  Future<void> deleteLocalPhoto(String filePath) async {
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}