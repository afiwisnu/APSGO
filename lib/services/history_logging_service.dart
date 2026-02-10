import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firebase_database_service.dart';
import 'automation_constants.dart';

/// Service untuk auto-logging data sensor ke Firebase history
/// Berjalan di background dan save snapshot setiap interval tertentu
class HistoryLoggingService {
  static final HistoryLoggingService _instance =
      HistoryLoggingService._internal();
  factory HistoryLoggingService() => _instance;
  HistoryLoggingService._internal();

  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();

  Timer? _loggingTimer;
  bool _isActive = false;

  // Interval logging (gunakan constant)
  Duration _loggingInterval = const Duration(
    minutes: AutomationConstants.historyLoggingIntervalMinutes,
  );

  /// Start history logging service
  void start({Duration? interval}) {
    if (_isActive) {
      debugPrint('📊 History logging already active');
      return;
    }

    if (interval != null) {
      _loggingInterval = interval;
    }

    _isActive = true;
    debugPrint(
      '📊 History logging started (interval: ${_loggingInterval.inMinutes} min)',
    );

    // Log immediately on start
    _logCurrentData();

    // Then log periodically
    _loggingTimer = Timer.periodic(_loggingInterval, (timer) {
      _logCurrentData();
    });
  }

  /// Stop history logging service
  void stop() {
    _loggingTimer?.cancel();
    _loggingTimer = null;
    _isActive = false;
    debugPrint('📊 History logging stopped');
  }

  /// Log current sensor data to Firebase history
  Future<void> _logCurrentData() async {
    try {
      final sensorData = await _dbService.getSensorData();

      if (sensorData.isNotEmpty) {
        await _dbService.saveHistory(sensorData);

        final now = DateTime.now();
        debugPrint(
          '📊 History logged: ${now.hour}:${now.minute.toString().padLeft(2, '0')} - '
          'Temp: ${sensorData['suhu']}°C, Soil1: ${sensorData['soil_1']}%',
        );
      } else {
        debugPrint('⚠️ No sensor data available to log');
      }
    } catch (e) {
      debugPrint('❌ Error logging history: $e');
    }
  }

  /// Manually trigger logging (useful for testing)
  Future<void> logNow() async {
    debugPrint('📊 Manual history log triggered');
    await _logCurrentData();
  }

  /// Change logging interval
  void setInterval(Duration newInterval) {
    _loggingInterval = newInterval;

    if (_isActive) {
      // Restart with new interval
      stop();
      start(interval: newInterval);
    }

    debugPrint('📊 Logging interval changed to: ${newInterval.inMinutes} min');
  }

  /// Get current status
  bool get isActive => _isActive;
  Duration get interval => _loggingInterval;

  /// Cleanup (call when app closes)
  void dispose() {
    stop();
  }
}
