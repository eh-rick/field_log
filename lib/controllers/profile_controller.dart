class ProfileController {
  static final ProfileController _instance = ProfileController._internal();
  factory ProfileController() => _instance;
  ProfileController._internal();

  Future<bool> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1)); 
    return false;
  }
}