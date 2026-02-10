# 🚀 Quick Start - Railway Worker Setup

## ✅ Apa yang Sudah Dibuat

### 1. Railway Worker (Node.js)
```
railway-worker/
├── worker.js           # Main worker code  
├── package.json        # Dependencies
├── railway.json        # Railway config
├── .env.example        # Environment template
└── README.md          # Worker documentation
```

**Features:**
- ✅ Waktu Mode (time-based scheduling)
- ✅ Sensor Mode (threshold automation)
- ✅ Auto history logging (10 min)
- ✅ Redis queue (prevent race conditions)
- ✅ Graceful shutdown & error handling

### 2. Flutter Bug Fixes
- ✅ Memory leak fixed (StreamSubscription disposal)
- ✅ AppLifecycle observer (stop services saat background)
- ✅ Connection monitoring service
- ✅ Constants untuk configuration
- ✅ Improved error handling

### 3. Documentation
- ✅ `DEPLOYMENT_GUIDE.md` - Langkah deploy ke Railway
- ✅ `BUGS_AND_FIXES.md` - Bug report & fixes
- ✅ `railway-worker/README.md` - Worker docs

---

## 📋 Langkah Deployment (Ringkas)

### Step 1: Firebase Setup
1. Download Service Account Key dari Firebase Console
2. Simpan: `project_id`, `client_email`, `private_key`

### Step 2: Railway Setup
1. Login ke [railway.app](https://railway.app)
2. Create new project → Deploy from GitHub
3. Add Redis database
4. Set root directory: `railway-worker`

### Step 3: Environment Variables
Di Railway, tambahkan:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`  
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_DATABASE_URL`

### Step 4: Deploy!
Railway auto-deploy setelah variables di-set.

### Step 5: Test
- Check logs untuk "Worker is running"
- Test waktu mode dari Flutter app
- Test sensor mode
- Monitor logs

**📖 Detail lengkap:** Lihat `DEPLOYMENT_GUIDE.md`

---

## 🎯 Kesimpulan

### Masalah yang Diselesaikan
1. ✅ **Scheduling hanya jalan saat app buka** → Sekarang 24/7 dengan Railway
2. ✅ **Memory leaks** → Fixed dengan proper disposal
3. ✅ **Race conditions** → Fixed dengan BullMQ queue
4. ✅ **No connection check** → Added monitoring service

### Arsitektur Baru
```
Flutter App ↔ Firebase RTDB ↔ Railway Worker (24/7) ↔ ESP32
                                    ↓
                               Redis Queue
```

### Biaya
- Railway Free Tier: $5/month credit (cukup untuk IoT project)
- Estimated usage: $3-5/month

---

## 🆘 Troubleshooting

**Worker tidak start:**
- Check `FIREBASE_PRIVATE_KEY` format (harus ada `\n`)
- Verify Redis service aktif

**Jadwal tidak trigger:**
- Check timezone (worker use UTC, convert dari local)
- Verify `/kontrol/waktu` = true

**Detail:** Lihat DEPLOYMENT_GUIDE.md section Troubleshooting

---

## 📞 Support

- Railway Discord: discord.gg/railway
- Firebase Support: firebase.google.com/support
- Project Issues: GitHub repository

---

**Selamat! Sistem Anda sekarang production-ready dengan automation 24/7! 🎉**
