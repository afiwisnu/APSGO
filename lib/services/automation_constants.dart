/// Constants untuk automation system
/// Centralized configuration untuk mudah maintenance
class AutomationConstants {
  AutomationConstants._(); // Private constructor untuk prevent instantiation

  // ==================== SENSOR THRESHOLDS ====================

  /// Default batas atas kelembapan tanah (%)
  static const int defaultBatasAtas = 100;

  /// Default batas bawah kelembapan tanah (%)
  static const int defaultBatasBawah = 40;

  /// Minimum kelembapan yang aman (%)
  static const int minSafeSoilMoisture = 0;

  /// Maximum kelembapan yang aman (%)
  static const int maxSafeSoilMoisture = 100;

  // ==================== TIMING CONFIGURATION ====================

  /// Default durasi penyiraman (detik)
  static const int defaultDurasiDetik = 60;

  /// Minimum durasi penyiraman (detik)
  static const int minDurasiDetik = 5;

  /// Maximum durasi penyiraman (detik)
  static const int maxDurasiDetik = 300; // 5 menit

  /// Interval check untuk waktu mode (detik)
  static const int waktuCheckInterval = 30;

  /// Interval check untuk sensor mode (detik)
  static const int sensorCheckInterval = 5;

  /// Cooldown minimum antar penyiraman per pot (detik)
  static const int wateringCooldownSeconds = 120; // 2 menit

  // ==================== HISTORY LOGGING ====================

  /// Interval auto-logging history (menit)
  static const int historyLoggingIntervalMinutes = 10;

  /// Maximum history retention days
  static const int historyRetentionDays = 30;

  // ==================== POT CONFIGURATION ====================

  /// Jumlah total pot dalam sistem
  static const int totalPots = 5;

  /// Mapping pot number ke mosfet number
  /// Pot 1 → mosvet_3, Pot 2 → mosvet_4, dst
  static int potToMosvet(int potNumber) {
    if (potNumber < 1 || potNumber > totalPots) {
      throw ArgumentError('Pot number must be between 1 and $totalPots');
    }
    return potNumber + 2;
  }

  // ==================== AKTUATOR MOSFET NAMES ====================

  static const String pompaAirMosfet = 'mosvet_1';
  static const String pompaPupukMosfet = 'mosvet_2';
  static const String pot1Mosfet = 'mosvet_3';
  static const String pot2Mosfet = 'mosvet_4';
  static const String pot3Mosfet = 'mosvet_5';
  static const String pot4Mosfet = 'mosvet_6';
  static const String pot5Mosfet = 'mosvet_7';
  static const String pengadukMosfet = 'mosvet_8';

  // ==================== SENSOR MODES ====================

  static const String modeSensorSmart = 'smart';
  static const String modeSensorFixed = 'fixed';

  // ==================== FIREBASE PATHS ====================

  static const String pathData = 'data';
  static const String pathAktuator = 'aktuator';
  static const String pathKontrol = 'kontrol';
  static const String pathHistory = 'history';
  static const String pathConnected = '.info/connected';

  // ==================== ERROR MESSAGES ====================

  static const String errorFirebaseConnection = 'Tidak ada koneksi ke Firebase';
  static const String errorInvalidPotNumber = 'Nomor pot tidak valid';
  static const String errorInvalidDuration = 'Durasi tidak valid';
  static const String errorInvalidThreshold = 'Nilai threshold tidak valid';
  static const String errorWateringActive = 'Penyiraman sedang berlangsung';

  // ==================== VALIDATION ====================

  /// Validate pot number
  static bool isValidPotNumber(int potNumber) {
    return potNumber >= 1 && potNumber <= totalPots;
  }

  /// Validate durasi
  static bool isValidDurasi(int durasi) {
    return durasi >= minDurasiDetik && durasi <= maxDurasiDetik;
  }

  /// Validate threshold
  static bool isValidThreshold(int value) {
    return value >= minSafeSoilMoisture && value <= maxSafeSoilMoisture;
  }

  /// Validate waktu format (HH:mm)
  static bool isValidWaktuFormat(String waktu) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(waktu);
  }
}
