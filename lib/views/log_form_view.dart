import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/log_form_controller.dart';

class LogFormView extends StatefulWidget {
  const LogFormView({super.key});

  @override
  State<LogFormView> createState() => _LogFormViewState();
}

class _LogFormViewState extends State<LogFormView> {
  final _formKey = GlobalKey<FormState>();
  final _speciesController = TextEditingController();
  final _countController = TextEditingController();
  final _notesController = TextEditingController();
  final _controller = LogFormController();

  @override
  void dispose() {
    _speciesController.dispose();
    _countController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  final success = await _controller.saveSighting(
    species: _speciesController.text.trim(),
    count: int.parse(_countController.text.trim()),
    notes: _notesController.text.trim(),
  );

  if (!mounted) return;

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sighting logged securely with accurate GPS status.')),
    );
    Navigator.pop(context);
  } else {
    // Show explicit error message if GPS resolution fails or permission was missing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_controller.locationError.isNotEmpty 
          ? _controller.locationError 
          : 'Failed to save sighting configuration.')),
    );
  }
}

  // Future<void> _submitForm() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final success = await _controller.saveSighting(
  //     species: _speciesController.text.trim(),
  //     count: int.parse(_countController.text.trim()),
  //     notes: _notesController.text.trim(),
  //     latitude: -22.5609, 
  //     longitude: 17.0658,
  //   );

  //   if (!mounted) return;

  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Sighting logged securely.')),
  //     );
  //     Navigator.pop(context);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to save sighting configuration.')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Sighting')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isSaving) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Species Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countController,
                  decoration: const InputDecoration(
                    labelText: 'Animal Count',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required field';
                    if (int.tryParse(val) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Field Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sighting Photos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _controller.capturedPhotoPaths.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _controller.capturedPhotoPaths.length) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: OutlinedButton(
                              onPressed: _controller.takePhoto,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.add_a_photo, size: 28),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_controller.capturedPhotoPaths[index]),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _controller.removePhoto(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Sighting Log'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}