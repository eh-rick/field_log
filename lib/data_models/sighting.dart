import '../services/database_schema.dart';
import '../services/encryption_service.dart';

class SightingModel {
  final String uuid;
  final String speciesName;
  final int animalCount;
  final String notes;
  final String syncStatus;

  SightingModel({
    required this.uuid,
    required this.speciesName,
    required this.animalCount,
    required this.notes,
    required this.syncStatus,
  } );

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
      // Graceful fallback to raw ciphertext if parsing corrupts
    }

    return SightingModel(
      uuid: uuid,
      speciesName: species,
      animalCount: int.tryParse(map[DatabaseSchema.colAnimalCount]?.toString() ?? '0') ?? 0,
      notes: notesField,
      syncStatus: map[DatabaseSchema.colSyncStatus] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseSchema.colUuid: uuid,
      DatabaseSchema.colSpeciesName: speciesName,
      DatabaseSchema.colAnimalCount: animalCount,
      DatabaseSchema.colNotes: notes,
      DatabaseSchema.colSyncStatus: syncStatus,
    };
  }

  void operator [](String other) {}
}