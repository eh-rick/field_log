import 'package:sqflite/sqflite.dart';

class DatabaseSchema {
  DatabaseSchema._(); 

  static const String tableUsers = 'users';
  static const String tableSightings = 'sightings';
  static const String tablePhotos = 'sighting_photos';
  static const String tableErrorLogs = 'error_logs';
  static const String tableAuditTrail = 'audit_trail';

  static const String colUuid = 'uuid';
  
  static const String colUsername = 'username';
  static const String colPasswordHash = 'password_hash';
  static const String colFullName = 'full_name';

  static const String colUserId = 'user_uuid';
  static const String colSpeciesName = 'species_name';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';
  static const String colAnimalCount = 'animal_count';
  static const String colNotes = 'notes';
  static const String colSyncStatus = 'sync_status';
  static const String colCreated = 'created';
  static const String colLastModified = 'last_modified';

  static const String colSightingId = 'sighting_id';
  static const String colLocalFilePath = 'local_file_path';

  static const String colErrorMessage = 'error_message';
  static const String colStackTrace = 'stack_trace';

  static const String colAction = 'action';
  static const String colTableName = 'table_name';
  static const String colRecordUuid = 'record_uuid';

  static const String _createUsersTable = '''
    CREATE TABLE $tableUsers (
      $colUuid TEXT PRIMARY KEY,
      $colUsername TEXT UNIQUE NOT NULL,
      $colPasswordHash TEXT NOT NULL,
      $colFullName TEXT NOT NULL
    )
  ''';

  static const String _createSightingsTable = '''
    CREATE TABLE $tableSightings (
      $colUuid TEXT PRIMARY KEY,
      $colUserId TEXT NOT NULL,
      $colSpeciesName TEXT NOT NULL,
      $colLatitude REAL NOT NULL,
      $colLongitude REAL NOT NULL,
      $colAnimalCount INTEGER NOT NULL,
      $colNotes TEXT,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending',
      $colCreated TEXT NOT NULL,
      $colLastModified TEXT NOT NULL,
      FOREIGN KEY ($colUserId) REFERENCES $tableUsers ($colUuid) ON DELETE RESTRICT
    )
  ''';

  static const String _createPhotosTable = '''
    CREATE TABLE $tablePhotos (
      $colUuid TEXT PRIMARY KEY,
      $colSightingId TEXT NOT NULL,
      $colLocalFilePath TEXT NOT NULL,
      FOREIGN KEY ($colSightingId) REFERENCES $tableSightings ($colUuid) ON DELETE CASCADE
    )
  ''';

  static const String _createErrorLogsTable = '''
    CREATE TABLE $tableErrorLogs (
      $colUuid TEXT PRIMARY KEY,
      $colErrorMessage TEXT NOT NULL,
      $colStackTrace TEXT,
      $colCreated TEXT NOT NULL
    )
  ''';

  static const String _createAuditTrailTable = '''
    CREATE TABLE $tableAuditTrail (
      $colUuid TEXT PRIMARY KEY,
      $colAction TEXT NOT NULL,
      $colTableName TEXT NOT NULL,
      $colRecordUuid TEXT NOT NULL,
      $colUserId TEXT NOT NULL,
      $colCreated TEXT NOT NULL
    )
  ''';

  static const String _idxCreated = 'CREATE INDEX idx_sightings_created ON $tableSightings ($colCreated)';
  static const String _idxSyncStatus = 'CREATE INDEX idx_sightings_sync ON $tableSightings ($colSyncStatus)';

  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute(_createUsersTable);
    batch.execute(_createSightingsTable);
    batch.execute(_createPhotosTable);
    batch.execute(_createErrorLogsTable);
    batch.execute(_createAuditTrailTable);
    batch.execute(_idxCreated);
    batch.execute(_idxSyncStatus);
    await batch.commit(noResult: true);
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {}
}