import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks device network connectivity. Used by the API client / repositories
/// to fail fast with a [NetworkFailure] instead of waiting for a timeout.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((results) => !results.contains(ConnectivityResult.none));
}
