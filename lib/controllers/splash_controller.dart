import 'package:field_log/services/sync_service.dart';
import 'package:flutter/material.dart';
import '../core/app_router.dart';
import '../services/database_service.dart';
import 'profile_controller.dart';

class SplashController {
  static final SplashController _instance = SplashController._internal();
  factory SplashController() => _instance;
  SplashController._internal();

  final _databaseService = DatabaseService();
  final _profileController = ProfileController();
  final _syncService = SyncService();

  Future<void> handleStartupNavigation(BuildContext context) async {
    await _databaseService.database;
    _syncService.initialize();
    
    final bool isLoggedIn = await _profileController.checkLoginStatus();

    if (!context.mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }
}