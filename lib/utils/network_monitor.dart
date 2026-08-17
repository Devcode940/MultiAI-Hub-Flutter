import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity monitor - mirrors Kotlin NetworkMonitor
class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._();
  static NetworkMonitor get instance => _instance;
  NetworkMonitor._();

  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((results) =>
          results.any((r) => r != ConnectivityResult.none));

  /// Check current connectivity
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
