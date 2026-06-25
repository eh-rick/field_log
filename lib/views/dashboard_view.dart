import 'package:field_log/controllers/dashboard_controller.dart';
import 'package:field_log/controllers/profile_controller.dart';
import 'package:field_log/services/database_schema.dart';
import 'package:flutter/material.dart';
import '../core/app_router.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
// import 'dashboard_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _controller = DashboardController();
  final _encryptionService = EncryptionService();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primaryContainer,
        title: Text(
          'Ranger Dashboard',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _controller.isOnline 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _controller.isOnline ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _controller.isOnline ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: _controller.isOnline ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _controller.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _controller.isOnline ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Pending Sync Banner
              if (_controller.pendingCount > 0)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync_problem, color: Colors.orange.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_controller.pendingCount} logs pending synchronization.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_controller.isOnline)
                        _controller.isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade800,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: _controller.syncPendingSightings,
                                child: const Text('SYNC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                    ],
                  ),
                ),

              // Sightings List Context
              Expanded(
                child: _controller.sightings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No sightings logged yet.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _controller.sightings.length,
                        itemBuilder: (context, index) {
                          final sighting = _controller.sightings[index];
                          final isSynced = sighting[DatabaseSchema.colSyncStatus] == 'synced';
                          final sightingUuid = sighting[DatabaseSchema.colUuid] as String? ?? '';

                          // Safe Inline Decryption for Fields
                          String displaySpecies = sighting[DatabaseSchema.colSpeciesName] as String? ?? 'Unknown';
                          String displayNotes = sighting[DatabaseSchema.colNotes] as String? ?? '';

                          try {
                            if (displaySpecies.endsWith('=')) {
                              displaySpecies = _encryptionService.decryptText(displaySpecies, sightingUuid);
                            }
                            if (displayNotes.isNotEmpty && displayNotes.endsWith('=')) {
                              displayNotes = _encryptionService.decryptText(displayNotes, sightingUuid);
                            }
                          } catch (_) {
                            // Fallback gracefully to raw text if decryption encounters structural errors
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Leading Visual Avatar Placeholder
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                    child: Icon(Icons.pets, color: theme.colorScheme.primary, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Data Columns
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displaySpecies,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Count: ${sighting[DatabaseSchema.colAnimalCount]}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (displayNotes.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            displayNotes,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey.shade500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  // Sync Status Badge Action Indicator
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isSynced ? Colors.green.shade50 : Colors.orange.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSynced ? Icons.check : Icons.access_time_rounded,
                                      size: 18,
                                      color: isSynced ? Colors.green.shade700 : Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/log-form');
          _controller.loadSightings();
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Sighting', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}