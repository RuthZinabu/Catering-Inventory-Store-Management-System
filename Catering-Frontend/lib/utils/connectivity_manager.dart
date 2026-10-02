import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Manages network connectivity state
class ConnectivityManager extends ChangeNotifier {
  static ConnectivityManager? _instance;
  static ConnectivityManager get instance {
    _instance ??= ConnectivityManager._internal();
    return _instance!;
  }

  ConnectivityManager._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = true;
  bool _hasShownOfflineMessage = false;

  bool get isConnected => _isConnected;
  bool get isOffline => !_isConnected;

  void _init() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateConnectionStatus(_hasActiveConnection(results));
      },
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(_hasActiveConnection(results));
    } catch (e) {
      _updateConnectionStatus(false);
    }
  }

  /// Determines if the device has an active internet connection
  /// based on the list of connectivity results
  bool _hasActiveConnection(List<ConnectivityResult> results) {
    // If the list is empty, consider it as no connection
    if (results.isEmpty) {
      return false;
    }

    // Check if all results are ConnectivityResult.none
    // If any result is not 'none', we have some form of connectivity
    for (final result in results) {
      if (result != ConnectivityResult.none) {
        return true;
      }
    }

    // All results are 'none', so no connection
    return false;
  }

  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;

      if (isConnected) {
        _hasShownOfflineMessage = false;
      }

      notifyListeners();
    }
  }

  /// Check if device is connected to internet with actual network test
  Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (!_hasActiveConnection(results)) {
        return false;
      }

      // Additional check by trying to resolve a known host
      // This is done in the ApiClient's isConnected method
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Show offline notification if not already shown
  void showOfflineNotification(BuildContext context) {
    if (!_hasShownOfflineMessage && isOffline) {
      _hasShownOfflineMessage = true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You\'re offline. Some features may not work properly.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show back online notification
  void showOnlineNotification(BuildContext context) {
    if (_hasShownOfflineMessage && isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'You\'re back online!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _hasShownOfflineMessage = false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Widget that listens to connectivity changes and shows notifications
class ConnectivityListener extends StatefulWidget {
  final Widget child;

  const ConnectivityListener({super.key, required this.child});

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  late final ConnectivityManager _connectivityManager;

  @override
  void initState() {
    super.initState();
    _connectivityManager = ConnectivityManager.instance;
    _connectivityManager.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _connectivityManager.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (!mounted) return;

    if (_connectivityManager.isOffline) {
      _connectivityManager.showOfflineNotification(context);
    } else {
      _connectivityManager.showOnlineNotification(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
