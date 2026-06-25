import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart';
import '../services/database_service.dart';
import '../services/database_schema.dart';

class LoginController extends ChangeNotifier {
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  LoginController._internal();

  final _dbService = DatabaseService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = SHA256Digest();
    final hashed = digest.process(Uint8List.fromList(bytes));
    return base64.encode(hashed);
  }

  Future<void> seedDefaultUser() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> users = await db.query(DatabaseSchema.tableUsers);
    
    if (users.isEmpty) {
      await db.insert(DatabaseSchema.tableUsers, {
        DatabaseSchema.colUuid: 'default-ranger-uuid-1234567890',
        DatabaseSchema.colUsername: 'ranger1',
        DatabaseSchema.colPasswordHash: _hashPassword('password123'),
        DatabaseSchema.colFullName: 'Field Ranger One',
      });
    }
  }

  Future<bool> login(String username, String password) async {
    
    _isLoading = true;
    notifyListeners();
    await seedDefaultUser();

    final db = await _dbService.database;
    final hashedPassword = _hashPassword(password);

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseSchema.tableUsers,
      where: '${DatabaseSchema.colUsername} = ? AND ${DatabaseSchema.colPasswordHash} = ?',
      whereArgs: [username, hashedPassword],
    );

    _isLoading = false;
    notifyListeners();

    return result.isNotEmpty;
  }
}