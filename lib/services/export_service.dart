import 'dart:io';
import 'package:field_log/data_models/sighting.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
 static final ExportService _instance = ExportService._internal();
 factory ExportService() => _instance;
 ExportService._internal();

  Future<String> exportSightingsToCSV( List<SightingModel> sightings ) async {
    try {
      final List<String> csvRows = [];
      csvRows.add( 'Sighting UUID,Species Name,Animal Count,Sync Status,Field Notes' );
      for ( final SightingModel sighting in sightings ) {
        final String cleanSpecies = sighting.speciesName.replaceAll( '"', '""' );
        final String cleanNotes = sighting.notes.replaceAll( '"', '""' );
        csvRows.add(
          '${sighting.uuid},"$cleanSpecies",${sighting.animalCount},${sighting.syncStatus},"$cleanNotes"'
        );
      }
      final String csvContent = csvRows.join( '\n' );
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/field_log_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final File file = File( path );
      await file.writeAsString( csvContent );
      return path;
    } catch ( e ) {
      debugPrint( 'ExportService: ${e.toString()}' );
    }
    return '';
  }
}