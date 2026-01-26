# Laporan Perbaikan Bug ApsGo

**Tanggal**: 26 Januari 2026  
**Status**: ✅ SELESAI

## Ringkasan Bug yang Diperbaiki

### 1. 🔒 Bug Logout Tiba-tiba ke Landing Page

**Masalah**:
- Aplikasi terkadang logout secara tiba-tiba saat klik menu Kontrol atau menu lainnya
- User ter-redirect ke Landing Page tanpa sengaja

**Penyebab**:
- Tidak ada monitoring auth state di DashboardPage
- Ketika Firebase Auth token expired atau ada perubahan auth state, tidak ada handler yang tepat
- Navigation stack tidak terlindungi dengan baik

**Solusi**:
✅ Tambahkan `authStateChanges` listener di `initState()` DashboardPage
```dart
@override
void initState() {
  super.initState();
  // Monitor auth state untuk mencegah logout tidak terduga
  _authService.authStateChanges.listen((user) {
    if (user == null && mounted) {
      // User logged out, redirect to login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  });
}
```

**File yang Diubah**:
- `lib/screens/dashboard_page.dart`

---

### 2. 💧 Bug Pompa Tidak Langsung Aktif Saat Soil Moisture Rendah

**Masalah**:
- Pompa terkadang tidak langsung aktif ketika soil moisture di bawah ambang bawah
- Delay response terlalu lama (10 detik)
- Cooldown period terlalu lama (5 menit)

**Penyebab**:
- Timer check sensor berjalan setiap 10 detik → terlalu lambat
- Cooldown 5 menit antar penyiraman → terlalu lama untuk kondisi kritis
- Kurang logging untuk debugging

**Solusi**:
✅ **Interval Check**: Ubah dari 10 detik → **5 detik** (lebih responsif)
```dart
_sensorCheckTimer = Timer.periodic(
  const Duration(seconds: 5),  // Sebelumnya: 10 detik
  (timer) => _checkSensorThreshold(),
);
```

✅ **Cooldown Period**: Kurangi dari 5 menit → **2 menit**
```dart
if (diff.inMinutes < 2) {  // Sebelumnya: 5 menit
  debugPrint('⏳ POT $potNumber: Cooldown active (${2 - diff.inMinutes} min remaining)');
  return;
}
```

✅ **Tambah Logging Detail**: 
- Log setiap check sensor dengan nilai threshold
- Log setiap trigger penyiraman
- Log progress penyiraman per 5 detik
- Log saat target tercapai

✅ **Pastikan Flag Reset**: Tambah delay sebelum reset flag untuk memastikan cleanup selesai
```dart
await Future.delayed(const Duration(milliseconds: 500));
_isWateringActive[potKey] = false;
```

✅ **Error Handling**: Tambahkan try-catch untuk matikan pompa saat error
```dart
} catch (e) {
  debugPrint('❌ Error watering pot by sensor: $e');
  // Matikan semua untuk safety
  try {
    await _dbService.setPompaAir(false);
    await _dbService.setPot(potNumber, false);
  } catch (cleanupError) {
    debugPrint('❌ Error during cleanup: $cleanupError');
  }
  _isWateringActive[potKey] = false;
}
```

**File yang Diubah**:
- `lib/services/kontrol_automation_service.dart`

---

### 3. 🔌 Verifikasi Mapping Soil Sensor ke Mosfet

**Masalah yang Diperiksa**:
- Apakah soil_1 bisa mempengaruhi mosvet_3 dst
- Apakah mapping soil_x ke mosvet_y sudah benar

**Hasil Verifikasi**:
✅ Mapping sudah **BENAR**:
```
soil_1 (Pot 1) → mosvet_3 (Valve Pot 1)
soil_2 (Pot 2) → mosvet_4 (Valve Pot 2)
soil_3 (Pot 3) → mosvet_5 (Valve Pot 3)
soil_4 (Pot 4) → mosvet_6 (Valve Pot 4)
soil_5 (Pot 5) → mosvet_7 (Valve Pot 5)
```

**Catatan**:
- mosvet_1 = Pompa Air
- mosvet_2 = Pompa Nutrisi
- mosvet_3 s/d mosvet_7 = Valve Pot 1-5

**Perbaikan**:
✅ Tambah komentar dan logging untuk memperjelas mapping
```dart
// pot 1 → mosvet_3, pot 2 → mosvet_4, ... pot 5 → mosvet_7
debugPrint('💧 Starting watering: POT $potNumber (mosvet_${potNumber + 2})');
```

✅ Tambah logging tracking nilai soil sensor
```dart
debugPrint('🌡️ soil_$i = $soilValue (threshold: $batasBawah)');
debugPrint('⚠️ $soilKey ($soilValue) < batasBawah ($batasBawah) → Triggering watering for POT $i');
```

**File yang Diubah**:
- `lib/services/kontrol_automation_service.dart`

---

## Perubahan Detail

### File: `lib/screens/dashboard_page.dart`

**Perubahan**:
1. Import `AuthService` 
2. Tambah instance `_authService` 
3. Tambah `initState()` dengan auth state listener

### File: `lib/services/kontrol_automation_service.dart`

**Perubahan**:
1. ✅ Timer interval: 10s → 5s (line ~183)
2. ✅ Cooldown: 5 min → 2 min (line ~248)
3. ✅ Tambah logging detail di `_checkSensorThreshold()` (line ~217)
4. ✅ Tambah logging mapping pot (line ~254)
5. ✅ Tambah logging progress watering (line ~265)
6. ✅ Tambah delay sebelum reset flag (line ~283)
7. ✅ Improve error handling dengan cleanup (line ~286)

---

## Testing Checklist

Setelah update, pastikan test hal-hal berikut:

### Auth & Navigation
- [ ] Login dan navigate ke Dashboard
- [ ] Klik menu Kontrol → tidak logout
- [ ] Klik menu Histori → tidak logout
- [ ] Buka drawer dan klik menu → tidak logout
- [ ] Test dengan koneksi internet ON/OFF
- [ ] Test dengan token yang akan expired

### Sensor Automation
- [ ] Aktifkan mode Sensor
- [ ] Set soil moisture di bawah batas bawah (misal: 25%)
- [ ] Cek pompa aktif dalam **< 5 detik**
- [ ] Cek valve pot yang tepat aktif (soil_1 → mosvet_3, dst)
- [ ] Cek log di console untuk tracking
- [ ] Test dengan multiple pot di bawah threshold bersamaan
- [ ] Test cooldown period (2 menit)

### Edge Cases
- [ ] Test saat Firebase disconnect
- [ ] Test saat sensor data tidak valid (0, null, string)
- [ ] Test saat automation service crash
- [ ] Test multiple user logout/login

---

## Logging untuk Debugging

Untuk monitor aktivitas, cek console log dengan pattern:

**Sensor Mode**:
```
🌡️ Sensor Mode: Started
🌡️ Checking thresholds: batas_bawah=30, batas_atas=80
🌡️ soil_1 = 25 (threshold: 30)
⚠️ soil_1 (25) < batasBawah (30) → Triggering watering for POT 1
💧 Starting watering: POT 1 (mosvet_3)
🌡️ Target: soil_1 should reach >= 80 (currently: 25)
💧 POT 1 watering: 5s, soil_1: 35
💧 POT 1 watering: 10s, soil_1: 50
✅ POT 1 reached target: 80 >= 80
✅ Sensor Mode: Watering completed for POT 1 (15s)
```

**Cooldown**:
```
⏳ POT 1: Cooldown active (1 min remaining)
```

**Errors**:
```
❌ Error watering pot by sensor: [error message]
❌ Error during cleanup: [error message]
```

---

## Rekomendasi Lanjutan

1. **Tambah UI Indicator**: Tampilkan status automation (active/inactive) di Dashboard
2. **Notification**: Push notification saat pompa aktif otomatis
3. **History Log**: Simpan log automation ke Firebase untuk review
4. **Manual Override**: Button untuk force stop automation
5. **Sensor Calibration**: UI untuk kalibrasi sensor soil moisture

---

## Kontak

Jika masih ada masalah setelah update ini, catat:
1. Timestamp kejadian
2. Screenshot console log
3. Nilai sensor saat kejadian
4. Action yang dilakukan user

Happy Gardening! 🌱
