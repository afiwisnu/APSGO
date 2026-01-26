# 📱 Panduan Mengubah Logo/Icon APK

## ✅ Cara 1: Otomatis dengan flutter_launcher_icons (SUDAH DISETUP)

### Langkah 1: Install Package
Saya sudah menambahkan `flutter_launcher_icons` ke `pubspec.yaml`. Sekarang jalankan:

```bash
flutter pub get
```

### Langkah 2: Siapkan Logo
**Requirement:**
- Format: PNG
- Ukuran: **1024x1024 px** (recommended) atau minimal 512x512 px
- Background: Transparent atau solid color
- File: `assets/images/logo_apsgo.png` (sudah ada)

**Jika ingin ganti logo:**
1. Siapkan file PNG 1024x1024 px
2. Replace file `assets/images/logo_apsgo.png`

### Langkah 3: Generate Icon
Jalankan command ini di terminal:

```bash
flutter pub run flutter_launcher_icons
```

### Langkah 4: Verify
Check folder ini, icon seharusnya sudah ter-generate:
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### Langkah 5: Build APK
```bash
flutter build apk --release
```

---

## 🎨 Cara 2: Manual (Advanced)

Jika cara otomatis tidak berhasil, gunakan cara manual:

### Langkah 1: Prepare Icon dengan Berbagai Ukuran

| Resolusi | Ukuran | Folder |
|----------|--------|--------|
| MDPI | 48x48 px | `mipmap-mdpi/` |
| HDPI | 72x72 px | `mipmap-hdpi/` |
| XHDPI | 96x96 px | `mipmap-xhdpi/` |
| XXHDPI | 144x144 px | `mipmap-xxhdpi/` |
| XXXHDPI | 192x192 px | `mipmap-xxxhdpi/` |

### Langkah 2: Replace File

Replace semua file `ic_launcher.png` di folder berikut:
```
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

### Langkah 3: Build APK
```bash
flutter build apk --release
```

---

## 🌟 Adaptive Icon (Android 8.0+) - Optional

Untuk icon yang lebih modern dengan adaptive background:

### Update pubspec.yaml:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/logo_apsgo.png"
  adaptive_icon_background: "#4CAF50"  # Warna background
  adaptive_icon_foreground: "assets/images/logo_apsgo.png"
```

### Generate:
```bash
flutter pub run flutter_launcher_icons
```

---

## 🛠️ Tools Online untuk Resize Icon

Jika tidak punya tool untuk resize, gunakan:

1. **Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/
2. **App Icon Generator**: https://appicon.co/
3. **Icon Kitchen**: https://icon.kitchen/

Upload logo 1024x1024, download semua ukuran, copy ke folder mipmap.

---

## 📝 Checklist

- [x] ✅ Package `flutter_launcher_icons` sudah ditambahkan
- [x] ✅ Konfigurasi di `pubspec.yaml` sudah disetup
- [ ] ⏳ Jalankan `flutter pub get`
- [ ] ⏳ Siapkan logo 1024x1024 px di `assets/images/logo_apsgo.png`
- [ ] ⏳ Jalankan `flutter pub run flutter_launcher_icons`
- [ ] ⏳ Build APK dengan `flutter build apk --release`

---

## ❓ Troubleshooting

**Q: Error "flutter_launcher_icons not found"**  
A: Jalankan `flutter pub get` dulu

**Q: Icon tidak berubah setelah install**  
A: Uninstall app dulu, baru install ulang APK baru

**Q: Logo terlihat terpotong**  
A: Gunakan logo dengan padding/margin agar tidak terpotong di adaptive icon

**Q: Ingin icon berbeda untuk debug & release**  
A: Tambahkan konfigurasi terpisah:
```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/images/logo_apsgo.png"
  image_path_android: "assets/images/logo_debug.png"  # untuk debug
```

---

## 🚀 Quick Command

Jalankan command ini secara berurutan:

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate icons
flutter pub run flutter_launcher_icons

# 3. Build APK
flutter build apk --release

# 4. APK location
# build/app/outputs/flutter-apk/app-release.apk
```

---

**Selamat! Icon APK Anda sekarang sudah bisa diganti! 🎉**
