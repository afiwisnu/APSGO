import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  static final FirebaseDatabaseService _instance =
      FirebaseDatabaseService._internal();
  factory FirebaseDatabaseService() => _instance;
  FirebaseDatabaseService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // ==================== SENSOR DATA ====================
  
  /// Get real-time stream of sensor data
  Stream<Map<String, dynamic>> getSensorDataStream() {
    return _database.child('data').onValue.map((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(
          event.snapshot.value as Map,
        );
        return {
          'suhu': _parseValue(data['suhu']),
          'kelembapan': _parseValue(data['kelembapan']),
          'ldr': _parseValue(data['ldr']),
          'soil_1': _parseValue(data['soil_1']),
          'soil_2': _parseValue(data['soil_2']),
          'soil_3': _parseValue(data['soil_3']),
          'soil_4': _parseValue(data['soil_4']),
          'soil_5': _parseValue(data['soil_5']),
        };
      }
      return {};
    });
  }

  /// Get sensor data once
  Future<Map<String, dynamic>> getSensorData() async {
    try {
      final snapshot = await _database.child('data').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return {
          'suhu': _parseValue(data['suhu']),
          'kelembapan': _parseValue(data['kelembapan']),
          'ldr': _parseValue(data['ldr']),
          'soil_1': _parseValue(data['soil_1']),
          'soil_2': _parseValue(data['soil_2']),
          'soil_3': _parseValue(data['soil_3']),
          'soil_4': _parseValue(data['soil_4']),
          'soil_5': _parseValue(data['soil_5']),
        };
      }
    } catch (e) {
      print('Error getting sensor data: $e');
    }
    return {};
  }

  // ==================== AKTUATOR CONTROL ====================
  
  /// Get real-time stream of aktuator status
  Stream<Map<String, bool>> getAktuatorStream() {
    return _database.child('aktuator').onValue.map((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(
          event.snapshot.value as Map,
        );
        return {
          'mosvet_1': data['mosvet_1'] ?? false, // Pompa Air
          'mosvet_2': data['mosvet_2'] ?? false, // Pompa Pupuk
          'mosvet_3': data['mosvet_3'] ?? false, // Valve 1
          'mosvet_4': data['mosvet_4'] ?? false, // Valve 2
          'mosvet_5': data['mosvet_5'] ?? false, // Valve 3
          'mosvet_6': data['mosvet_6'] ?? false, // Valve 4
          'mosvet_7': data['mosvet_7'] ?? false, // Valve 5
        };
      }
      return {};
    });
  }

  /// Set aktuator status (untuk kontrol manual)
  Future<void> setAktuator(String mosfetName, bool value) async {
    try {
      await _database.child('aktuator/$mosfetName').set(value);
    } catch (e) {
      print('Error setting aktuator: $e');
      rethrow;
    }
  }

  // ==================== KONTROL CONFIG ====================
  
  /// Get real-time stream of kontrol configuration
  Stream<Map<String, dynamic>> getKontrolStream() {
    return _database.child('kontrol').onValue.map((event) {
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return {};
    });
  }

  /// Get kontrol configuration once
  Future<Map<String, dynamic>> getKontrolConfig() async {
    try {
      final snapshot = await _database.child('kontrol').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print('Error getting kontrol config: $e');
    }
    return {};
  }

  /// Update kontrol configuration
  Future<void> updateKontrolConfig(Map<String, dynamic> config) async {
    try {
      await _database.child('kontrol').update(config);
    } catch (e) {
      print('Error updating kontrol config: $e');
      rethrow;
    }
  }

  /// Set batas threshold (batas_atas, batas_bawah)
  Future<void> setThreshold({int? batasAtas, int? batasBawah}) async {
    try {
      final updates = <String, dynamic>{};
      if (batasAtas != null) updates['batas_atas'] = batasAtas;
      if (batasBawah != null) updates['batas_bawah'] = batasBawah;
      await _database.child('kontrol').update(updates);
    } catch (e) {
      print('Error setting threshold: $e');
      rethrow;
    }
  }

  /// Set waktu penyiraman
  Future<void> setWaktuPenyiraman({
    String? waktu1,
    String? waktu2,
    bool? waktuEnabled,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (waktu1 != null) updates['waktu_1'] = waktu1;
      if (waktu2 != null) updates['waktu_2'] = waktu2;
      if (waktuEnabled != null) updates['waktu'] = waktuEnabled;
      await _database.child('kontrol').update(updates);
    } catch (e) {
      print('Error setting waktu: $e');
      rethrow;
    }
  }

  /// Set durasi penyiraman
  Future<void> setDurasi({int? durasi1, int? durasi2}) async {
    try {
      final updates = <String, dynamic>{};
      if (durasi1 != null) updates['durasi_1'] = durasi1;
      if (durasi2 != null) updates['durasi_2'] = durasi2;
      await _database.child('kontrol').update(updates);
    } catch (e) {
      print('Error setting durasi: $e');
      rethrow;
    }
  }

  /// Toggle mode otomatis
  Future<void> setOtomatis(bool value) async {
    try {
      await _database.child('kontrol/otomatis').set(value);
    } catch (e) {
      print('Error setting otomatis: $e');
      rethrow;
    }
  }

  // ==================== HELPER FUNCTIONS ====================
  
  /// Parse value dari Firebase (handle empty string)
  String _parseValue(dynamic value) {
    if (value == null || value == '') {
      return '0';
    }
    return value.toString();
  }

  /// Get database reference (untuk advanced usage)
  DatabaseReference get databaseRef => _database;

  /// Check connection status
  Stream<bool> getConnectionStatus() {
    return _database.child('.info/connected').onValue.map((event) {
      return event.snapshot.value as bool? ?? false;
    });
  }
}
