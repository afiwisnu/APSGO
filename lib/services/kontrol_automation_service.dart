import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firebase_database_service.dart';

/// Service untuk menghandle logika otomatis kontrol waktu dan sensor
/// Berjalan di background untuk monitoring dan eksekusi otomatis
class KontrolAutomationService {
  static final KontrolAutomationService _instance =
      KontrolAutomationService._internal();
  factory KontrolAutomationService() => _instance;
  KontrolAutomationService._internal();

  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();

  Timer? _waktuCheckTimer;
  Timer? _sensorCheckTimer;
  StreamSubscription? _sensorSubscription;
  StreamSubscription? _kontrolSubscription;

  bool _isWaktuModeActive = false;
  bool _isSensorModeActive = false;

  // State untuk mencegah trigger berulang
  Map<String, DateTime> _lastWateringTime = {};
  Map<String, bool> _isWateringActive = {};

  // ==================== KONTROL WAKTU ====================

  /// Start monitoring waktu mode
  /// Cek setiap menit apakah ada jadwal yang harus dijalankan
  void startWaktuMode() {
    if (_isWaktuModeActive) return;

    _isWaktuModeActive = true;
    debugPrint('🕐 Waktu Mode: Started');

    // Cek setiap 30 detik
    _waktuCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _checkScheduledWatering(),
    );

    // Jalankan check pertama kali
    _checkScheduledWatering();
  }

  /// Stop monitoring waktu mode
  void stopWaktuMode() {
    _waktuCheckTimer?.cancel();
    _waktuCheckTimer = null;
    _isWaktuModeActive = false;
    debugPrint('🕐 Waktu Mode: Stopped');
  }

  /// Check apakah ada jadwal penyiraman yang harus dijalankan
  Future<void> _checkScheduledWatering() async {
    try {
      final kontrolConfig = await _dbService.getKontrolConfig();
      final waktuEnabled = kontrolConfig['waktu'] ?? false;

      if (!waktuEnabled || !_isWaktuModeActive) return;

      final now = DateTime.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final waktu1 = kontrolConfig['waktu_1'] ?? '';
      final waktu2 = kontrolConfig['waktu_2'] ?? '';
      final durasi1 = kontrolConfig['durasi_1'] ?? 60; // detik
      final durasi2 = kontrolConfig['durasi_2'] ?? 60; // detik

      // Check Jadwal 1
      if (waktu1.isNotEmpty &&
          _shouldStartWatering('jadwal_1', currentTime, waktu1)) {
        debugPrint('🕐 Executing Jadwal 1 at $currentTime');
        await _executeWatering(
          scheduleId: 'jadwal_1',
          pompaAir: true,
          pompaPupuk: true,
          pots: [1, 2, 3, 4, 5], // Semua pot
          durasiDetik: durasi1,
        );
      }

      // Check Jadwal 2
      if (waktu2.isNotEmpty &&
          _shouldStartWatering('jadwal_2', currentTime, waktu2)) {
        debugPrint('🕐 Executing Jadwal 2 at $currentTime');
        await _executeWatering(
          scheduleId: 'jadwal_2',
          pompaAir: true,
          pompaPupuk: true,
          pots: [1, 2, 3, 4, 5], // Semua pot
          durasiDetik: durasi2,
        );
      }
    } catch (e) {
      debugPrint('❌ Error checking scheduled watering: $e');
    }
  }

  /// Check apakah jadwal harus dijalankan
  bool _shouldStartWatering(
    String scheduleId,
    String currentTime,
    String targetTime,
  ) {
    // Cek apakah waktu sekarang sama dengan target
    if (currentTime != targetTime) return false;

    // Cek apakah sudah berjalan
    if (_isWateringActive[scheduleId] == true) return false;

    // Cek apakah sudah pernah dijalankan dalam 1 menit terakhir (prevent double trigger)
    final lastTime = _lastWateringTime[scheduleId];
    if (lastTime != null) {
      final diff = DateTime.now().difference(lastTime);
      if (diff.inSeconds < 60) return false;
    }

    return true;
  }

  /// Execute penyiraman dengan durasi tertentu
  Future<void> _executeWatering({
    required String scheduleId,
    required bool pompaAir,
    required bool pompaPupuk,
    required List<int> pots,
    required int durasiDetik,
  }) async {
    try {
      _isWateringActive[scheduleId] = true;
      _lastWateringTime[scheduleId] = DateTime.now();

      // Nyalakan pompa dan valve
      final updates = <String, bool>{};
      if (pompaAir) updates['mosvet_1'] = true;
      if (pompaPupuk) updates['mosvet_2'] = true;

      for (var pot in pots) {
        if (pot >= 1 && pot <= 5) {
          updates['mosvet_${pot + 2}'] = true;
        }
      }

      await _dbService.setMultipleAktuator(updates);
      debugPrint('✅ Watering started: $updates');

      // Tunggu sesuai durasi
      await Future.delayed(Duration(seconds: durasiDetik));

      // Matikan semua
      final offUpdates = <String, bool>{};
      updates.forEach((key, _) => offUpdates[key] = false);
      await _dbService.setMultipleAktuator(offUpdates);

      debugPrint('✅ Watering completed for $scheduleId');
      _isWateringActive[scheduleId] = false;
    } catch (e) {
      debugPrint('❌ Error executing watering: $e');
      _isWateringActive[scheduleId] = false;
    }
  }

  // ==================== KONTROL SENSOR ====================

  /// Start monitoring sensor mode
  void startSensorMode() {
    if (_isSensorModeActive) return;

    _isSensorModeActive = true;
    debugPrint('🌡️ Sensor Mode: Started');

    // Monitor perubahan sensor setiap beberapa detik
    _sensorCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) => _checkSensorThreshold(),
    );

    // Listen to sensor data real-time
    _sensorSubscription = _dbService.getSensorDataStream().listen((sensorData) {
      if (_isSensorModeActive) {
        _processSensorData(sensorData);
      }
    });

    // Jalankan check pertama kali
    _checkSensorThreshold();
  }

  /// Stop monitoring sensor mode
  void stopSensorMode() {
    _sensorCheckTimer?.cancel();
    _sensorCheckTimer = null;
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _isSensorModeActive = false;
    debugPrint('🌡️ Sensor Mode: Stopped');
  }

  /// Check sensor threshold untuk semua pot
  Future<void> _checkSensorThreshold() async {
    try {
      final kontrolConfig = await _dbService.getKontrolConfig();
      final otomatisEnabled = kontrolConfig['otomatis'] ?? false;

      if (!otomatisEnabled || !_isSensorModeActive) return;

      final batasAtas = kontrolConfig['batas_atas'] ?? 100;
      final batasBawah = kontrolConfig['batas_bawah'] ?? 40;

      final sensorData = await _dbService.getSensorData();

      // Check setiap pot (soil_1 sampai soil_5)
      for (int i = 1; i <= 5; i++) {
        final soilKey = 'soil_$i';
        final soilValue = int.tryParse(sensorData[soilKey] ?? '0') ?? 0;

        // Jika kelembapan di bawah batas bawah, siram pot tersebut
        if (soilValue < batasBawah) {
          await _waterPotBySensor(
            potNumber: i,
            soilValue: soilValue,
            batasBawah: batasBawah,
            batasAtas: batasAtas,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking sensor threshold: $e');
    }
  }

  /// Process sensor data real-time
  void _processSensorData(Map<String, dynamic> sensorData) {
    // Could be used for real-time alerts or logging
    // For now, the periodic check is sufficient
  }

  /// Siram pot berdasarkan sensor
  Future<void> _waterPotBySensor({
    required int potNumber,
    required int soilValue,
    required int batasBawah,
    required int batasAtas,
  }) async {
    final potKey = 'pot_$potNumber';

    // Prevent multiple watering in short time
    if (_isWateringActive[potKey] == true) return;

    final lastTime = _lastWateringTime[potKey];
    if (lastTime != null) {
      final diff = DateTime.now().difference(lastTime);
      if (diff.inMinutes < 5) return; // Minimum 5 menit antar penyiraman
    }

    try {
      _isWateringActive[potKey] = true;
      _lastWateringTime[potKey] = DateTime.now();

      debugPrint(
        '🌡️ Sensor Mode: Watering POT $potNumber (soil: $soilValue < $batasBawah)',
      );

      // Nyalakan pompa air dan valve pot tersebut
      await _dbService.setPompaAir(true);
      await _dbService.setPot(potNumber, true);

      // Siram sampai mencapai batas atas atau max 60 detik
      int elapsedSeconds = 0;
      const maxDuration = 60;

      while (elapsedSeconds < maxDuration && _isSensorModeActive) {
        await Future.delayed(const Duration(seconds: 5));
        elapsedSeconds += 5;

        // Check sensor lagi
        final currentData = await _dbService.getSensorData();
        final currentSoil =
            int.tryParse(currentData['soil_$potNumber'] ?? '0') ?? 0;

        if (currentSoil >= batasAtas) {
          debugPrint(
            '✅ POT $potNumber reached target: $currentSoil >= $batasAtas',
          );
          break;
        }
      }

      // Matikan pompa dan valve
      await _dbService.setPompaAir(false);
      await _dbService.setPot(potNumber, false);

      debugPrint('✅ Sensor Mode: Watering completed for POT $potNumber');
      _isWateringActive[potKey] = false;
    } catch (e) {
      debugPrint('❌ Error watering pot by sensor: $e');
      _isWateringActive[potKey] = false;
    }
  }

  // ==================== UTILITY ====================

  /// Get status semua automation
  Map<String, bool> getAutomationStatus() {
    return {'waktuMode': _isWaktuModeActive, 'sensorMode': _isSensorModeActive};
  }

  /// Stop semua automation
  void stopAll() {
    stopWaktuMode();
    stopSensorMode();
    debugPrint('⏹️ All automation stopped');
  }

  /// Cleanup saat app dispose
  void dispose() {
    stopAll();
    _kontrolSubscription?.cancel();
  }
}
