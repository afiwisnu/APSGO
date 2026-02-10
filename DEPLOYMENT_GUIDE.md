# 🚀 Railway Deployment Guide - ApsGo Worker

Panduan lengkap untuk deploy Railway Worker ke cloud Railway.app dan mengintegrasikannya dengan aplikasi Flutter ApsGo.

## 📋 Prerequisites

Sebelum memulai, pastikan Anda sudah punya:

1. ✅ Akun Railway.app (gratis) - [Daftar di sini](https://railway.app)
2. ✅ Firebase project dengan Realtime Database
3. ✅ Git installed di komputer
4. ✅ Node.js installed (v18+) untuk testing lokal (optional)

## 📁 Struktur Project

```
ApsGo/
├── lib/                    # Flutter app
├── android/
├── railway-worker/         # ← Worker yang akan di-deploy
│   ├── worker.js           # Main worker code
│   ├── package.json
│   ├── railway.json        # Railway config
│   ├── .env.example        # Environment variables template
│   └── README.md
└── README.md
```

---

## 🔧 STEP 1: Setup Firebase Service Account

Worker butuh Firebase Admin SDK untuk akses database. Ikuti langkah berikut:

### 1.1. Download Service Account Key

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project ApsGo Anda
3. Klik ⚙️ **Project Settings** (di sidebar kiri)
4. Tab **Service Accounts**
5. Klik **Generate New Private Key**
6. Download file JSON (jangan share file ini ke siapapun!)

### 1.2. Extract Credentials dari JSON

Buka file JSON yang di-download, cari 3 informasi ini:

```json
{
  "type": "service_account",
  "project_id": "your-project-id-123",           // ← SIMPAN INI
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n....\n-----END PRIVATE KEY-----\n",  // ← SIMPAN INI
  "client_email": "firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com",  // ← SIMPAN INI
  ...
}
```

Simpan 3 nilai ini, akan digunakan di Step 3.

### 1.3. Get Firebase Database URL

Format: `https://YOUR-PROJECT-ID-default-rtdb.firebaseio.com`

Cek di Firebase Console → Realtime Database → Copy URL di bagian atas.

---

## 🚂 STEP 2: Setup Railway Project

### 2.1. Login ke Railway

1. Buka [railway.app](https://railway.app)
2. Klik **Login** → Login dengan GitHub (recommended)
3. Authorize Railway untuk akses GitHub Anda

### 2.2. Create New Project

1. Klik **New Project**
2. Pilih **Deploy from GitHub repo**
3. Jika belum connect GitHub:
   - Klik **Configure GitHub App**
   - Authorize Railway
   - Pilih repository **ApsGo**

4. Railway akan scan repository Anda

### 2.3. Setup Worker Service

1. Railway detect root project (Flutter), kita perlu custom path
2. Klik **Settings** (di sidebar kiri service)
3. Scroll ke **Build & Deploy**
4. Set **Root Directory**: `railway-worker`
5. **Build Command**: `npm install`
6. **Start Command**: `npm start`
7. Klik **Save Changes**

### 2.4. Add Redis Service

Worker butuh Redis untuk queue system:

1. Klik **New** (di sidebar project)
2. Pilih **Database** → **Add Redis**
3. Railway akan auto-provision Redis
4. Redis akan otomatis terhubung ke worker (melalui private network)

---

## 🔐 STEP 3: Configure Environment Variables

### 3.1. Add Variables di Railway

1. Klik service **worker** (bukan Redis)
2. Klik tab **Variables**
3. Tambahkan variables berikut:

| Variable Name | Value | Cara Isi |
|--------------|--------|----------|
| `FIREBASE_PROJECT_ID` | your-project-id-123 | Dari Step 1.2 |
| `FIREBASE_CLIENT_EMAIL` | firebase-adminsdk-xxx@... | Dari Step 1.2 |
| `FIREBASE_PRIVATE_KEY` | "-----BEGIN PRIVATE KEY..." | Copy SELURUH private_key dari JSON, pastikan ada quotes |
| `FIREBASE_DATABASE_URL` | https://xxx.firebaseio.com | Dari Step 1.3 |

### 3.2. Redis Variables (Auto)

Railway akan auto-inject Redis variables:
- `REDIS_HOST`: `redis.railway.internal` (auto)
- `REDIS_PORT`: `6379` (auto)
- `REDIS_PASSWORD`: (auto-generated)

Atau Railway bisa provide single variable:
- `REDIS_URL`: `redis://default:password@redis.railway.internal:6379`

Worker code sudah handle both formats.

### 3.3. IMPORTANT: Format Private Key

Private key HARUS include newlines (`\n`). Contoh:

```
"-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBg...\n...akhir key...\n-----END PRIVATE KEY-----\n"
```

**Jika error "Invalid key":**
1. Pastikan ada quotes di awal dan akhir
2. Pastikan ada `\n` (bukan enter sesungguhnya)
3. Copy paste langsung dari JSON file

---

## 🚀 STEP 4: Deploy!

### 4.1. Trigger Deployment

Setelah environment variables di-set:

1. Railway akan auto-deploy
2. Atau klik **Deploy** → **Redeploy**

### 4.2. Monitor Deployment

1. Klik tab **Deployments**
2. Lihat build logs:
   - ✅ `npm install` berhasil
   - ✅ `npm start` running
   - ✅ Firebase initialized
   - ✅ Redis connected

3. Jika error, check **Logs** tab

### 4.3. Check Worker Logs

Setelah deploy sukses, check logs:

```
🚀 Starting ApsGo Railway Worker...
📡 Firebase Project: your-project-id
📦 Redis: redis.railway.internal:6379
✅ Firebase Admin initialized
✅ Redis connected
✅ Waktu Mode scheduler started (check every 30s)
✅ Sensor Mode monitoring started
✅ Auto history logging started (every 10 minutes)
✅ History cleanup scheduled (daily at 2 AM)
✨ ApsGo Railway Worker is running!
🎯 Worker is ready to process jobs...
```

Jika lihat log seperti ini, **SUKSES!** ✅

---

## 🧪 STEP 5: Testing Worker

### 5.1. Test Waktu Mode

1. Buka Flutter app ApsGo
2. Masuk ke **Kontrol** → **Waktu Mode**
3. Set jadwal 1 menit dari sekarang (misal: sekarang 14:05, set 14:06)
4. Set durasi: 10 detik
5. Save configuration

**Di Railway Logs, tunggu 1 menit:**
```
🕐 JADWAL 1 TRIGGERED: 14:06
   📌 Added to queue: jadwal_1_2026-02-10_14:06

💧 Processing Job: jadwal_1_2026-02-10_14:06
   Type: waktu_jadwal_1
   Pots: [1, 2, 3, 4, 5]
   Duration: 10s
   🔛 Turning ON: mosvet_1, mosvet_2, mosvet_3, mosvet_4...
   ⏳ 10s remaining...
   🔴 Turning OFF
   📊 History logged: 2026-02-10 14:06
   ✅ Job completed successfully
```

**Check di Flutter app:**
- Pompa dan valve nyala selama 10 detik
- Histori tercatat di halaman Histori

### 5.2. Test Sensor Mode

1. Buka **Kontrol** → **Sensor Mode**
2. Set batas_bawah: 50%
3. Enable otomatis
4. Set durasi_sensor: 15 detik

**Simulasi sensor:**
- Update Firebase Realtime DB manual:
  - Path: `/data/soil_1`
  - Value: `30` (di bawah 50%)

**Di Railway Logs:**
```
🌡️ SENSOR TRIGGERED: POT 1
   Soil moisture: 30% < 50%
   Mode: fixed, Duration: 15s
   📌 Added to queue: sensor-pot-1-1707562800000

💧 Processing Job: sensor-pot-1-1707562800000
   Type: sensor_threshold
   Pots: [1]
   Duration: 15s
   🔛 Turning ON: mosvet_1, mosvet_3
   ⏳ 15s remaining...
   🔴 Turning OFF
   ✅ Job completed successfully
```

### 5.3. Test Auto History Logging

**Check setiap 10 menit:**
```
📊 Auto-logged sensor data: 14:10
📊 Auto-logged sensor data: 14:20
📊 Auto-logged sensor data: 14:30
```

Verify di Firebase Console → Realtime Database → `/history`

---

## 📊 STEP 6: Monitoring & Maintenance

### 6.1. Health Check

Worker auto health check setiap 5 menit:

```
💚 HEALTH CHECK:
   Firebase: ✅ Connected
   Redis: ✅ Connected
   Queue: 0 active, 0 waiting
```

### 6.2. View Metrics di Railway

1. Klik service **worker**
2. Tab **Metrics**:
   - CPU Usage
   - Memory Usage
   - Network Traffic

3. Tab **Logs**:
   - Real-time logs
   - Filter by time/keyword

### 6.3. Setup Alerts (Optional)

1. Klik **Settings** → **Notifications**
2. Connect Slack/Discord/Email
3. Get notified jika service down

### 6.4. Restart Worker

**Manual Restart:**
1. Tab **Deployments**
2. Klik **...** (three dots)
3. **Redeploy**

**Auto Restart:**
- Railway auto-restart jika crash (configured in `railway.json`)

---

## 💰 STEP 7: Billing & Cost Management

### 7.1. Railway Free Tier

**Limits:**
- $5 credit per month (gratis)
- Cukup untuk small IoT project
- Auto-sleep jika idle (configurable)

**Typical Usage (ApsGo Worker):**
- Worker: ~$2-3/month
- Redis: ~$1-2/month
- **Total**: ~$3-5/month (masih dalam free tier!)

### 7.2. Upgrade to Hobby Plan (Optional)

Jika butuh lebih:
- $5/month
- More resources
- No sleep
- Priority support

---

## 🔧 TROUBLESHOOTING

### Problem: "Firebase initialization failed"

**Solution:**
1. Check `FIREBASE_PRIVATE_KEY` format
2. Pastikan ada quotes dan `\n`
3. Verify project ID benar
4. Check Firebase rules allow admin access

### Problem: "Redis connection error"

**Solution:**
1. Pastikan Redis service aktif di Railway
2. Check Redis variables auto-injected
3. Restart worker service

### Problem: "Worker tidak trigger jadwal"

**Solution:**
1. Check timezone: Worker use UTC
   - Convert waktu lokal ke UTC
   - Atau set `TZ` env variable: `Asia/Jakarta`
2. Check Firebase `/kontrol/waktu` = `true`
3. Check logs untuk error

### Problem: "Memory leak / High CPU"

**Solution:**
1. Check logs untuk infinite loop
2. Verify cooldown working
3. Check Redis queue size: `await queue.getJobCounts()`

### Problem: "Too many Firebase reads"

**Solution:**
1. Worker optimize untuk minimize reads
2. Check sensor mode `otomatis` tidak stuck ON
3. Consider increase check interval di code

---

## 🔄 STEP 8: Update Worker Code

### 8.1. Update via Git

1. Edit code di `railway-worker/worker.js`
2. Commit & push ke GitHub:
   ```bash
   git add .
   git commit -m "Update worker logic"
   git push
   ```
3. Railway auto-detect push → auto-deploy

### 8.2. Rollback Deployment

Jika ada bug setelah update:

1. Tab **Deployments**
2. Pilih deployment sebelumnya yang sukses
3. Klik **...** → **Redeploy**

---

## 📱 STEP 9: Integrate dengan Flutter App

### 9.1. Update App Logic

**PENTING:** Sekarang scheduling di-handle oleh Railway Worker, bukan Flutter app.

**Rekomendasi perubahan:**
1. **Disable** local automation services ketika deploy ke production
2. Keep local services hanya untuk **testing/development**
3. Tambahkan indicator di UI: "Server-side automation active"

### 9.2. Add Status Indicator (Optional)

Tambahkan di Flutter app untuk show worker status:

```dart
// Check worker last activity
final historyRef = FirebaseDatabase.instance.ref('history');
final lastLog = await historyRef.limitToLast(1).once();

if (lastLog.snapshot.value != null) {
  // Worker active (logged dalam 10 menit terakhir)
  showWorkerActiveIcon();
}
```

---

## 🎉 STEP 10: Done!

Congratulations! Worker Anda sekarang berjalan 24/7 di cloud.

**Apa yang terjadi sekarang:**
- ✅ Jadwal waktu berjalan otomatis (meskipun HP mati)
- ✅ Sensor monitoring aktif terus
- ✅ History auto-logged setiap 10 menit
- ✅ Old history auto-cleanup setiap hari
- ✅ Reliable, scalable, production-ready

**Next Steps:**
1. Monitor logs selama 24 jam pertama
2. Fine-tune configuration (durasi, threshold, dll)
3. Setup alerts untuk critical errors
4. Consider backup strategy untuk history data

---

## 📚 Additional Resources

- [Railway Documentation](https://docs.railway.app)
- [BullMQ Documentation](https://docs.bullmq.io)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## 🆘 Need Help?

- Railway Discord: [discord.gg/railway](https://discord.gg/railway)
- Firebase Support: [firebase.google.com/support](https://firebase.google.com/support)
- ApsGo Issues: Create issue di GitHub repository

---

## 📝 Checklist Deployment

Copy checklist ini untuk reference:

- [ ] Firebase Service Account downloaded
- [ ] Railway account created
- [ ] GitHub repository connected
- [ ] Redis service added
- [ ] Environment variables configured
- [ ] Worker deployed successfully
- [ ] Logs showing "Worker is running"
- [ ] Waktu Mode tested
- [ ] Sensor Mode tested
- [ ] Auto logging verified
- [ ] Monitoring setup
- [ ] Flutter app updated (optional)
- [ ] Documentation completed

---

**🎊 Happy Automating! Selamat menggunakan ApsGo dengan Railway Worker!**
