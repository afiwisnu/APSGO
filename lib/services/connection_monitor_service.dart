import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firebase_database_service.dart';

/// Service untuk monitoring koneksi Firebase
/// Memberikan status koneksi realtime dan handle reconnection
class ConnectionMonitorService {
  static final ConnectionMonitorService _instance =
      ConnectionMonitorService._internal();
  factory ConnectionMonitorService() => _instance;
  ConnectionMonitorService._internal();

  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();

  StreamSubscription? _connectionSubscription;
  bool _isConnected = false;
  final _connectionController = StreamController<bool>.broadcast();

  // Callbacks untuk connection status changes
  final List<Function(bool)> _connectionListeners = [];

  /// Start monitoring connection
  void start() {
    if (_connectionSubscription != null) {
      debugPrint('🌐 Connection monitor already running');
      return;
    }

    debugPrint('🌐 Starting connection monitor');

    _connectionSubscription = _dbService.getConnectionStatus().listen((
      connected,
    ) {
      _isConnected = connected;
      _connectionController.add(connected);

      if (connected) {
        debugPrint('✅ Firebase connected');
      } else {
        debugPrint('❌ Firebase disconnected');
      }

      // Notify all listeners
      for (var listener in _connectionListeners) {
        try {
          listener(connected);
        } catch (e) {
          debugPrint('⚠️ Error in connection listener: $e');
        }
      }
    });
  }

  /// Stop monitoring connection
  void stop() {
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    debugPrint('🌐 Connection monitor stopped');
  }

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Stream of connection status changes
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Add listener untuk connection changes
  void addConnectionListener(Function(bool connected) listener) {
    _connectionListeners.add(listener);
  }

  /// Remove listener
  void removeConnectionListener(Function(bool connected) listener) {
    _connectionListeners.remove(listener);
  }

  /// Wait until connected (dengan timeout)
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isConnected) return true;

    try {
      final connected = await connectionStream
          .firstWhere((connected) => connected)
          .timeout(timeout);
      return connected;
    } on TimeoutException {
      debugPrint('⏰ Connection timeout');
      return false;
    } catch (e) {
      debugPrint('❌ Error waiting for connection: $e');
      return false;
    }
  }

  /// Cleanup
  void dispose() {
    stop();
    _connectionController.close();
    _connectionListeners.clear();
  }
}
