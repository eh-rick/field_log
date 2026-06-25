import 'package:shared_preferences/shared_preferences.dart';

class ProfileController {
  static final ProfileController _instance = ProfileController._internal();
  factory ProfileController() => _instance;
  ProfileController._internal();

  static const String _keyIsLoggedIn = 'is_logged_in';

  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false; 
  }

  Future<bool> saveLoginStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool test = await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    return test;
  }

  Future<void> clearLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
  }
}