import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// NetworkInfo
/// Provides network connectivity information and monitoring.
/// Used to determine if device has active internet connection.
///
/// Features:
/// - Check current connectivity status
/// - Monitor connectivity changes
/// - Determine connection type (WiFi, Mobile, None)
/// - Reactive connectivity stream
class NetworkInfo extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  
  ConnectivityResult _currentStatus = ConnectivityResult.none;
  bool _isConnected = false;

  // Getters
  ConnectivityResult get currentStatus => _currentStatus;
  bool get isConnected => _isConnected;
  bool get isWifi => _currentStatus == ConnectivityResult.wifi;
  bool get isMobile => _currentStatus == ConnectivityResult.mobile;
  bool get isOffline => _currentStatus == ConnectivityResult.none;

  /// Get connection type as string
  String get connectionType {
    switch (_currentStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  NetworkInfo() {
    _initialize();
  }

  /// Initialize network monitoring
  void _initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
      return _isConnected;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      _currentStatus = ConnectivityResult.none;
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    _currentStatus = result;
    _isConnected = result != ConnectivityResult.none;

    debugPrint('📡 Connectivity changed: ${connectionType} (Connected: $_isConnected)');
    
    notifyListeners();
  }

  /// Wait for connection to become available
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return;

    debugPrint('⏳ Waiting for connection...');

    final completer = Completer<void>();
    
    final subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(timeout);
      debugPrint('✅ Connection available');
    } catch (e) {
      debugPrint('⏰ Timeout waiting for connection');
    } finally {
      await subscription.cancel();
    }
  }

  /// Get connectivity status as enum
  Future<ConnectivityResult> getConnectivityResult() async {
    return await _connectivity.checkConnectivity();
  }

  /// Check if specific connection type is available
  bool hasConnectionType(ConnectivityResult type) {
    return _currentStatus == type;
  }
}