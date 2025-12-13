import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// ConnectivityService
/// 
/// Advanced connectivity monitoring service with retry logic and status 
/// tracking. Provides real-time connection status updates and automatic 
/// reconnection handling.
///
/// Features:
/// - Real-time connectivity monitoring
/// - Connection status history
/// - Retry logic with exponential backoff
/// - Connection quality estimation
/// - Event notifications for connectivity changes

class ConnectivityService extends ChangeNotifier {

  ConnectivityService() {
    _initialize();
  }
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Connection state
  ConnectivityResult _currentConnection = ConnectivityResult.none;
  bool _isConnected = false;
  DateTime? _lastConnectedTime;
  DateTime? _lastDisconnectedTime;
  int _disconnectionCount = 0;

  // Connection history (last 10 events)
  final List<ConnectivityEvent> _connectionHistory = [];
  static const int _maxHistoryLength = 10;

  // Retry logic
  Timer? _retryTimer;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 5;
  static const Duration _initialRetryDelay = Duration(seconds: 2);

  // Getters
  ConnectivityResult get currentConnection => _currentConnection;
  bool get isConnected => _isConnected;
  DateTime? get lastConnectedTime => _lastConnectedTime;
  DateTime? get lastDisconnectedTime => _lastDisconnectedTime;
  int get disconnectionCount => _disconnectionCount;
  List<ConnectivityEvent> get connectionHistory => 
      List.unmodifiable(_connectionHistory);
  bool get isRetrying => _retryTimer?.isActive ?? false;
  int get retryAttempts => _retryAttempts;

  /// Connection quality estimation
  ConnectionQuality get connectionQuality {
    if (!_isConnected) return ConnectionQuality.none;
    
    switch (_currentConnection) {
      case ConnectivityResult.wifi:
        return ConnectionQuality.excellent;
      case ConnectivityResult.mobile:
        return ConnectionQuality.good;
      case ConnectivityResult.ethernet:
        return ConnectionQuality.excellent;
      default:
        return ConnectionQuality.poor;
    }
  }

  /// Connection status as string
  String get statusText {
    if (!_isConnected) return 'Offline';
    
    switch (_currentConnection) {
      case ConnectivityResult.wifi:
        return 'Connected via WiFi';
      case ConnectivityResult.mobile:
        return 'Connected via Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected via Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityResult.vpn:
        return 'Connected via VPN';
      default:
        return 'Connected';
    }
  }

  /// Initialize connectivity monitoring
  Future<void> _initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Start monitoring
    _startMonitoring();
  }

  /// Start connectivity monitoring
  void _startMonitoring() {
    _connectivitySubscription = 
        _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) {
        debugPrint('❌ Connectivity stream error: $error');
      },
    );
  }

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
      return _isConnected;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      _handleConnectivityChange(ConnectivityResult.none);
      return false;
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    final previousConnection = _currentConnection;
    final wasConnected = _isConnected;

    _currentConnection = result;
    _isConnected = result != ConnectivityResult.none;

    // Connection restored
    if (!wasConnected && _isConnected) {
      _onConnectionRestored();
    }

    // Connection lost
    if (wasConnected && !_isConnected) {
      _onConnectionLost();
    }

    // Connection type changed
    if (wasConnected && 
        _isConnected && 
        previousConnection != _currentConnection) {
      _onConnectionTypeChanged(previousConnection, _currentConnection);
    }

    // Add to history
    _addToHistory(ConnectivityEvent(
      connectionType: result,
      isConnected: _isConnected,
      timestamp: DateTime.now(),
    ),);

    debugPrint('📡 Connectivity: $statusText');
    notifyListeners();
  }

  /// Handle connection restored
  void _onConnectionRestored() {
    _lastConnectedTime = DateTime.now();
    _retryAttempts = 0;
    _retryTimer?.cancel();

    debugPrint('✅ Connection restored: $statusText');
  }

  /// Handle connection lost
  void _onConnectionLost() {
    _lastDisconnectedTime = DateTime.now();
    _disconnectionCount++;

    debugPrint('❌ Connection lost (Count: $_disconnectionCount)');

    // Start retry logic
    _startRetryLogic();
  }

  /// Handle connection type changed
  void _onConnectionTypeChanged(
    ConnectivityResult from,
    ConnectivityResult to,
  ) {
    debugPrint(
        '🔄 Connection type changed: '
        '${_connectionTypeToString(from)} → ${_connectionTypeToString(to)}'
    );
  }

  /// Start retry logic with exponential backoff
  void _startRetryLogic() {
    _retryTimer?.cancel();
    _retryAttempts = 0;

    _scheduleRetry();
  }

  /// Schedule next retry attempt
  void _scheduleRetry() {
    if (_retryAttempts >= _maxRetryAttempts) {
      debugPrint('⚠️ Max retry attempts reached');
      return;
    }

    // Exponential backoff: 2s, 4s, 8s, 16s, 32s
    final delay = _initialRetryDelay * (1 << _retryAttempts);
    
    debugPrint(
        '🔄 Scheduling retry #${_retryAttempts + 1} '
        'in ${delay.inSeconds}s'
    );

    _retryTimer = Timer(delay, _performRetry);

    notifyListeners();
  }

  /// Perform retry attempt
  Future<void> _performRetry() async {
    _retryAttempts++;
    notifyListeners();

    final connected = await checkConnectivity();
    
    if (!connected) {
      _scheduleRetry();
    }
  }

  /// Cancel retry logic
  void cancelRetry() {
    _retryTimer?.cancel();
    _retryAttempts = 0;
    notifyListeners();
  }

  /// Add event to connection history
  void _addToHistory(ConnectivityEvent event) {
    _connectionHistory.insert(0, event);
    
    // Keep only last N events
    if (_connectionHistory.length > _maxHistoryLength) {
      _connectionHistory.removeRange(
          _maxHistoryLength, 
          _connectionHistory.length,
      );
    }
  }

  /// Get connection type as string
  String _connectionTypeToString(ConnectivityResult result) {
    switch (result) {
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
        return 'None';
      default:
        return 'Unknown';
    }
  }

  /// Wait for connection with timeout
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_isConnected) return true;

    debugPrint(
        '⏳ Waiting for connection '
        '(timeout: ${timeout.inSeconds}s)...'
    );

    final completer = Completer<bool>();
    StreamSubscription<ConnectivityResult>? subscription;

    subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
        subscription?.cancel();
      }
    });

    try {
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () {
          subscription?.cancel();
          return false;
        },
      );

      if (result) {
        debugPrint('✅ Connection available');
      } else {
        debugPrint('⏰ Timeout waiting for connection');
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error waiting for connection: $e');
      subscription.cancel();
      return false;
    }
  }

  /// Reset statistics
  void resetStatistics() {
    _disconnectionCount = 0;
    _connectionHistory.clear();
    _lastConnectedTime = null;
    _lastDisconnectedTime = null;
    notifyListeners();
  }

  /// Get uptime (time since last disconnection)
  Duration? get uptime {
    if (_lastConnectedTime == null) return null;
    return DateTime.now().difference(_lastConnectedTime!);
  }

  /// Get downtime (time since last connection)
  Duration? get downtime {
    if (!_isConnected && _lastDisconnectedTime != null) {
      return DateTime.now().difference(_lastDisconnectedTime!);
    }
    return null;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}

/// Connectivity event model
class ConnectivityEvent {

  ConnectivityEvent({
    required this.connectionType,
    required this.isConnected,
    required this.timestamp,
  });
  final ConnectivityResult connectionType;
  final bool isConnected;
  final DateTime timestamp;

  String get description {
    if (!isConnected) return 'Disconnected';
    
    switch (connectionType) {
      case ConnectivityResult.wifi:
        return 'Connected via WiFi';
      case ConnectivityResult.mobile:
        return 'Connected via Mobile';
      case ConnectivityResult.ethernet:
        return 'Connected via Ethernet';
      default:
        return 'Connected';
    }
  }
}

/// Connection quality enum
enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}