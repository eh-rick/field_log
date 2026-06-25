import 'package:field_log/controllers/dashboard_controller.dart';
import 'package:field_log/services/database_schema.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranger Dashboard'),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Icon(
                _controller.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: _controller.isOnline ? Colors.green : Colors.red,
              );
            },
          ),
          const SizedBox(width: 16),
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
              if (_controller.pendingCount > 0)
                Container(
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_controller.pendingCount} logs pending synchronization.',
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                      ),
                      if (_controller.isOnline)
                        _controller.isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : TextButton(
                                onPressed: _controller.syncPendingSightings,
                                child: const Text('SYNC NOW'),
                              ),
                    ],
                  ),
                ),
              Expanded(
                child: _controller.sightings.isEmpty
                    ? const Center(child: Text('No sightings logged yet.'))
                    : ListView.builder(
                        itemCount: _controller.sightings.length,
                        itemBuilder: (context, index) {
                          final sighting = _controller.sightings[index];
                          final isSynced = sighting[DatabaseSchema.colSyncStatus] == 'synced';

                          return ListTile(
                            title: Text(sighting[DatabaseSchema.colSpeciesName] as String),
                            subtitle: Text('Count: ${sighting[DatabaseSchema.colAnimalCount]}'),
                            trailing: Icon(
                              isSynced ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSynced ? Colors.green : Colors.orange,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/log-form');
          _controller.loadSightings();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}