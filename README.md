# Kişisel Harcama Koçu

Yapay zeka destekli, Türkçe kişisel finans uygulaması. Gelir/gider takibi, analiz, takvim ve **Gemini tabanlı Finans Koçu** ile bilinçli harcama kararları.

## Canlı demo

| Bileşen | URL |
|---------|-----|
| Web uygulaması | *(deploy sonrası güncelle)* |
| Backend API | *(deploy sonrası `/health` URL)* |

## Ne yapar?

- E-posta / Google ile giriş
- Gelir-gider kaydı, kategori yönetimi, aylık özet
- Pasta grafik analizi, takvim görünümü
- **AI Finans Koçu** — gerçek harcama verilerine dayalı sohbet ve aylık analiz
- Offline-first (Drift/SQLite) + Firebase Firestore senkronu

## Proje yapısı

```
├── frontend/       Flutter uygulaması (Android, iOS, Web)
├── backend/        Node.js REST API (Gemini LLM proxy)
├── prodocs/        Ürün ve geliştirme dokümanları
├── .env.example    Ortam değişkeni şablonu
└── README.md       Bu dosya
```

**Dokümanlar:** [prodocs/PRD.md](prodocs/PRD.md) · [tech-stack](prodocs/tech-stack.md) · [Plan](prodocs/Plan.md) · [DesignSystem](prodocs/DesignSystem.md) · [Progress](prodocs/Progress.md)

## Hızlı başlangıç

### 1. Backend

```powershell
cd backend
copy .env.example .env
# .env içine GEMINI_API_KEY ve FIREBASE_PROJECT_ID ekle
npm install
npm run dev
```

Backend `http://localhost:3001` adresinde çalışır.

### 2. Frontend

**Chrome (önerilen — emülatör sorununda):**
```powershell
cd frontend
flutter pub get
.\run_chrome.ps1
```

**Android emülatör:**
```powershell
cd frontend
.\run_emulator.ps1 -ColdBoot
```

> AI koç için backend açık olmalı. Emülatörde `adb reverse tcp:3001 tcp:3001` gerekir (`run_emulator.ps1` otomatik yapar).

### 3. Firebase

1. Firebase Console'da Auth (E-posta + Google) ve Firestore etkinleştir
2. `flutterfire configure` komutunu `frontend/` klasöründe çalıştır
3. Firestore kurallarını deploy et: `firebase deploy --only firestore:rules`

## Canlıya alma

### Backend → Render

1. [render.com](https://render.com) üzerinde Web Service oluştur
2. Root Directory: `backend`
3. Env: `GEMINI_API_KEY`, `FIREBASE_PROJECT_ID`, `FIREBASE_SERVICE_ACCOUNT`, `CORS_ORIGINS`

### Frontend Web → Firebase Hosting

```powershell
cd frontend
flutter build web --dart-define=BACKEND_URL=https://YOUR-BACKEND.onrender.com
cd ..
firebase deploy --only hosting
```

## API

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/health` | Sağlık kontrolü |
| POST | `/api/v1/coach/chat` | Finans koçu sohbeti |
| POST | `/api/v1/coach/analyze` | Aylık AI finans özeti |

## Güvenlik

Gerçek API anahtarları ve veritabanı şifreleri **asla** repoya commit edilmemelidir. Şablon için `.env.example` ve `backend/.env.example` dosyalarına bakın.
