import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KontrolStorage {
  static const String _keyManualPompaAir = 'manual_pompa_air';
  static const String _keyManualPompaNutrisi = 'manual_pompa_nutrisi';
  static const String _keyManualPots = 'manual_pots';
  static const String _keyWaktuConfig = 'waktu_config_';
  static const String _keySensorConfig = 'sensor_config_';
  static const String _keyWaktuModeActive = 'waktu_mode_active';
  static const String _keySensorModeActive = 'sensor_mode_active';

  // Manual Control - Save
  static Future<void> saveManualControl({
    required bool pompaAir,
    required bool pompaNutrisi,
    required List<bool> pots,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyManualPompaAir, pompaAir);
    await prefs.setBool(_keyManualPompaNutrisi, pompaNutrisi);
    await prefs.setString(_keyManualPots, jsonEncode(pots));
  }

  // Manual Control - Load
  static Future<Map<String, dynamic>> loadManualControl() async {
    final prefs = await SharedPreferences.getInstance();
    final pompaAir = prefs.getBool(_keyManualPompaAir) ?? false;
    final pompaNutrisi = prefs.getBool(_keyManualPompaNutrisi) ?? false;
    final potsJson = prefs.getString(_keyManualPots);
    List<bool> pots = [false, false, false, false, false];

    if (potsJson != null) {
      final decoded = jsonDecode(potsJson) as List;
      pots = decoded.map((e) => e as bool).toList();
      // Ensure we have 5 pots
      while (pots.length < 5) {
        pots.add(false);
      }
    }

    return {'pompaAir': pompaAir, 'pompaNutrisi': pompaNutrisi, 'pots': pots};
  }

  // Waktu Config - Save
  static Future<void> saveWaktuConfig(
    String potName,
    List<Map<String, dynamic>> jadwal,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWaktuConfig + potName, jsonEncode(jadwal));
  }

  // Waktu Config - Load
  static Future<List<Map<String, dynamic>>> loadWaktuConfig(
    String potName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyWaktuConfig + potName);

    if (json != null) {
      final decoded = jsonDecode(json) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Default values
    return [
      {
        'jamMulai': '08:00',
        'durasi': '10',
        'durasiUnit': 'menit',
        'pompaAir': false,
        'pompaPupuk': false,
      },
      {
        'jamMulai': '16:00',
        'durasi': '10',
        'durasiUnit': 'menit',
        'pompaAir': false,
        'pompaPupuk': false,
      },
    ];
  }

  // Sensor Config - Save
  static Future<void> saveSensorConfig(
    String potName,
    Map<String, dynamic> config,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySensorConfig + potName, jsonEncode(config));
  }

  // Sensor Config - Load
  static Future<Map<String, dynamic>> loadSensorConfig(String potName) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keySensorConfig + potName);

    if (json != null) {
      return Map<String, dynamic>.from(jsonDecode(json));
    }

    // Default values
    return {
      'batasMinimal': '30',
      'batasMaksimal': '80',
      'durasi': '10',
      'durasiUnit': 'menit',
    };
  }

  // Mode Active Status - Save
  static Future<void> saveWaktuModeActive(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWaktuModeActive, isActive);
  }

  static Future<void> saveSensorModeActive(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySensorModeActive, isActive);
  }

  // Mode Active Status - Load
  static Future<bool> loadWaktuModeActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWaktuModeActive) ?? false;
  }

  static Future<bool> loadSensorModeActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySensorModeActive) ?? false;
  }
}
