import 'package:field_log/controllers/base_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends BaseController  {
  static final ProfileController _instance = ProfileController._internal();
  factory ProfileController() => _instance;
  ProfileController._internal();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserUuid = 'current_user_uuid';
  

  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false; 
  }

  Future<bool> saveLoginStatus({required bool isLoggedIn, required String userUuid}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool statusSave = await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    bool uuidSave = await prefs.setString(_keyUserUuid, userUuid);
    return statusSave && uuidSave;
  }

  Future<void> clearLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
  }
}