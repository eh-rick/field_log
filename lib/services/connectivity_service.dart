import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  ConnectivityService._internal() {
    _connectivity.onConnectivityChanged.listen((results) async {
      final hasInternet = await _verifyActualSignal(results);
      _statusController.add(hasInternet);
    });
  }

  Stream<bool> get onConnectivityChanged => _statusController.stream;

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return await _verifyActualSignal(results);
  }

  Future<bool> _verifyActualSignal(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}