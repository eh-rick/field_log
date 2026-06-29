import '../services/database_schema.dart';
import '../services/encryption_service.dart';

class SightingModel {
  final String uuid;
  final String userUuid;
  final String speciesName;
  final double latitude;
  final double longitude;
  final int animalCount;
  final String notes;
  final String syncStatus;
  final String created;

  SightingModel({
    required this.uuid,
    required this.userUuid,
    required this.speciesName,
    required this.latitude,
    required this.longitude,
    required this.animalCount,
    required this.notes,
    required this.syncStatus,
    required this.created,
  });

  factory SightingModel.fromEncryptedMap(Map<String, dynamic> map, EncryptionService crypto) {
    final uuid = map[DatabaseSchema.colUuid] as String? ?? '';
    String species = map[DatabaseSchema.colSpeciesName] as String? ?? 'Unknown';
    String notesField = map[DatabaseSchema.colNotes] as String? ?? '';

    try {
      if (species.endsWith('=')) {
        species = crypto.decryptText(species, uuid);
      }
      if (notesField.isNotEmpty && notesField.endsWith('=')) {
        notesField = crypto.decryptText(notesField, uuid);
      }
    } catch (_) {
    }

    return SightingModel(
      uuid: uuid,
      userUuid: map[DatabaseSchema.colUserId] as String? ?? '',
      speciesName: species,
      latitude: double.tryParse(map[DatabaseSchema.colLatitude]?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(map[DatabaseSchema.colLongitude]?.toString() ?? '0.0') ?? 0.0,
      animalCount: int.tryParse(map[DatabaseSchema.colAnimalCount]?.toString() ?? '0') ?? 0,
      notes: notesField,
      syncStatus: map[DatabaseSchema.colSyncStatus] as String? ?? 'pending',
      created: map[DatabaseSchema.colCreated] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseSchema.colUuid: uuid,
      DatabaseSchema.colUserId: userUuid,
      DatabaseSchema.colSpeciesName: speciesName,
      DatabaseSchema.colLatitude: latitude,
      DatabaseSchema.colLongitude: longitude,
      DatabaseSchema.colAnimalCount: animalCount,
      DatabaseSchema.colNotes: notes,
      DatabaseSchema.colSyncStatus: syncStatus,
      DatabaseSchema.colCreated: created,
    };
  }
}