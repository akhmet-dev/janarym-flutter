import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Monitors network connectivity.
class NetworkMonitor extends ChangeNotifier {
  static final NetworkMonitor shared = NetworkMonitor._();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkMonitor._() {
    _init();
  }

  void _init() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
    Connectivity().checkConnectivity().then((results) {
      _isConnected = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
