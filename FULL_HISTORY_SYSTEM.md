# Full History System Implementation

## 📋 Overview
Sistem history lengkap yang mencatat dan menampilkan data sensor dari Firebase secara otomatis.

## 🔧 Komponen

### 1. **History Logging Service** 
File: `lib/services/history_logging_service.dart`

**Fungsi:**
- Auto-save data sensor setiap **10 menit**
- Persistent - berjalan otomatis saat app aktif
- Cleanup otomatis data lama (>30 hari)

**Key Features:**
```dart
- interval: Duration(minutes: 10)
- Auto start saat Firebase initialized
- isActive property untuk check status
```

### 2. **Firebase Database Service Updates**
File: `lib/services/firebase_database_service.dart`

**Method Baru:**
- `saveHistory()` - Simpan snapshot data sensor
- `getHistoryByDateRange()` - Load data berdasarkan range tanggal
- `getLatestHistory()` - Load data terbaru (100 entries)
- `clearOldHistory()` - Hapus data >30 hari

### 3. **History Page Lengkap**
File: `lib/screens/histori_page.dart`

**Fitur:**
- ✅ Load data real dari Firebase
- ✅ Filter by date range
- ✅ Filter per pot atau semua pot
- ✅ Hitung rata-rata otomatis
- ✅ Refresh manual dengan IconButton
- ✅ Loading states
- ✅ Error handling
- ✅ Empty state info
- ✅ Auto load last 7 days by default

### 4. **Main App Integration**
File: `lib/main.dart`

**Changes:**
- Import HistoryLoggingService
- Start service saat Firebase initialized
- Service berjalan global di background

## 📊 Struktur Data Firebase

```
/history
  /2024-12-28
    /14:30
      {
        suhu: 28.5,
        kelembapan: 65.2,
        ldr: 820,
        soil_1: 45.2,
        soil_2: 52.1,
        soil_3: 48.7,
        soil_4: 50.3,
        soil_5: 46.9,
        timestamp: 1703761800000
      }
    /14:40
      {...}
```

## 🎯 Flow Data

1. **Auto Logging (Background)**
   ```
   App Start → Firebase Init → HistoryLoggingService.start()
   → Timer (10 min) → saveHistory() → Firebase /history
   ```

2. **Manual Load (UI)**
   ```
   User Opens Histori Page → Load Default (7 days)
   → getHistoryByDateRange() → Calculate Averages → Display
   ```

3. **Filter & Refresh**
   ```
   User Selects Date Range → _loadHistoryData()
   → Display Updated Data
   
   User Clicks Refresh → _loadHistoryData() → Display
   ```

## 📱 UI Features

### Overall Averages
- Suhu Rata-Rata
- Kelembaban Udara Rata-Rata
- LDR Rata-Rata

### Per Pot Averages
- Expandable cards untuk setiap pot
- Detail: Suhu, Kelembaban, Soil Moisture, Light

### Filter Options
- Date Range Picker (calendar UI)
- Pot Selector (dropdown)
  - Semua Pot
  - Pot 1
  - Pot 2
  - Pot 3
  - Pot 4
  - Pot 5

## 🚀 How to Use

### For Users
1. Buka tab "Histori"
2. Data akan otomatis dimuat (7 hari terakhir)
3. Klik calendar icon untuk pilih date range
4. Pilih pot dari dropdown untuk filter
5. Klik refresh icon untuk reload data

### For Developers
```dart
// Start logging service
final loggingService = HistoryLoggingService();
loggingService.start();

// Stop logging service (optional)
loggingService.stop();

// Check if active
if (loggingService.isActive) {
  print('Service is running');
}

// Get history data
final dbService = FirebaseDatabaseService();
final history = await dbService.getHistoryByDateRange(
  DateTime.now().subtract(Duration(days: 7)),
  DateTime.now(),
);
```

## ⚙️ Configuration

### Logging Interval
Edit `lib/services/history_logging_service.dart`:
```dart
static const Duration interval = Duration(minutes: 10); // Change here
```

### Data Retention
Edit `lib/services/firebase_database_service.dart`:
```dart
await clearOldHistory(30); // Keep last 30 days
```

## 🔍 Testing Checklist

- [ ] Service start otomatis saat app launch
- [ ] Data tersimpan setiap 10 menit
- [ ] History page load data dari Firebase
- [ ] Filter date range berfungsi
- [ ] Filter per pot berfungsi
- [ ] Calculate averages akurat
- [ ] Refresh button berfungsi
- [ ] Loading states tampil
- [ ] Error handling works
- [ ] Empty state tampil jika no data

## ⚠️ Important Notes

1. **First Time Use**: Data history akan mulai tersimpan setelah 10 menit pertama. Sebelum itu, akan menampilkan data saat ini.

2. **Firebase Rules**: Pastikan Firebase Realtime Database rules allow read/write untuk /history:
   ```json
   {
     "rules": {
       "history": {
         ".read": "auth != null",
         ".write": "auth != null"
       }
     }
   }
   ```

3. **Performance**: Cleanup otomatis data >30 hari untuk menjaga performa database.

4. **Memory**: Service menggunakan Timer, pastikan stop() dipanggil jika tidak dibutuhkan lagi (optional, karena global service).

## 📈 Future Enhancements

Possible improvements:
- Export data to CSV
- Chart/graph visualization
- Notification untuk anomali data
- Configurable logging interval dari UI
- Data comparison antar pot
- Weekly/Monthly summary reports

## 🐛 Troubleshooting

**Problem**: Data tidak tersimpan
- Check Firebase connection
- Check auth status
- Check console logs untuk error message

**Problem**: History page kosong
- Tunggu 10 menit untuk data pertama
- Check Firebase rules
- Check internet connection

**Problem**: Service tidak start
- Check Firebase initialization
- Check console logs
- Restart app

## 📝 Change Log

### v1.0 - Full History System
- ✅ Auto-logging service (10 min interval)
- ✅ Complete history page with Firebase integration
- ✅ Date range filter
- ✅ Per pot filtering
- ✅ Automatic averages calculation
- ✅ Cleanup old data (>30 days)
- ✅ Loading & error states
- ✅ Manual refresh option

---
**Status**: ✅ FULLY IMPLEMENTED
**Last Updated**: December 2024
