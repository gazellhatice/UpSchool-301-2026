# Kişisel Harcama Koçu

Yapay zeka destekli, Türkçe kişisel finans uygulaması. Gelir/gider takibi, analiz, takvim ve **Gemini tabanlı Finans Koçu** ile bilinçli harcama kararları.

## Canlı Demo

| Bileşen | URL |
|---------|-----|
| **Web uygulaması** | `https://<firebase-project>.web.app` *(deploy sonrası güncelle)* |
| **Backend API** | `https://<render-service>.onrender.com/health` *(deploy sonrası güncelle)* |

## Ne Yapar?

- E-posta / Google ile giriş
- Gelir-gider kaydı, kategori yönetimi, aylık özet
- Pasta grafik analizi, takvim görünümü
- **AI Finans Koçu** — kullanıcının gerçek harcama verilerine dayalı sohbet ve aylık analiz
- Offline-first (Drift/SQLite) + Firebase Firestore senkronu

## Proje Yapısı

```
├── frontend/          Flutter uygulaması (Android, iOS, Web)
├── backend/           Node.js REST API (Gemini LLM proxy)
├── prodocs/           AI ajan referans dosyaları
├── PRD.md             Ürün gereksinimleri
├── tech-stack.md      Teknoloji seçimleri
├── Plan.md            Teknik uygulama planı
├── DesignSystem.md    Tasarım sistemi
└── Progress.md        Geliştirme günlüğü
```

## Hızlı Başlangıç

### 1. Backend

```bash
cd backend
cp .env.example .env
# .env içine GEMINI_API_KEY ve FIREBASE_PROJECT_ID ekle
npm install
npm run dev
```

Backend `http://localhost:3001` adresinde çalışır.

### 2. Frontend

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:3001
```

Android için:

```bash
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3001
```

### 3. Firebase

1. Firebase Console'da Auth (E-posta + Google) ve Firestore etkinleştir
2. `flutterfire configure` komutunu `frontend/` klasöründe çalıştır
3. Firestore kurallarını deploy et:

```bash
firebase deploy --only firestore:rules
```

## Canlıya Alma (Deploy)

### Backend → Render

1. [render.com](https://render.com) üzerinde yeni Web Service oluştur
2. Root Directory: `backend`
3. Environment variables: `GEMINI_API_KEY`, `FIREBASE_PROJECT_ID`, `FIREBASE_SERVICE_ACCOUNT`, `CORS_ORIGINS`
4. Deploy sonrası URL'yi not al (ör. `https://kisisel-harcama-kocu-api.onrender.com`)

### Frontend Web → Firebase Hosting

```bash
cd frontend
flutter build web --dart-define=BACKEND_URL=https://YOUR-BACKEND.onrender.com
cd ..
firebase deploy --only hosting
```

### Android APK

```bash
cd frontend
flutter build apk --dart-define=BACKEND_URL=https://YOUR-BACKEND.onrender.com
```

## API Endpoints

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/health` | Sağlık kontrolü |
| POST | `/api/v1/coach/chat` | Finans koçu sohbeti |
| POST | `/api/v1/coach/analyze` | Aylık AI finans özeti |

## Ortam Değişkenleri

Kök `.env.example` ve `backend/.env.example` dosyalarına bakın. **Gerçek API anahtarları asla repoya commit edilmemelidir.**

## Demo Video

Maksimum 5 dakikalık demo videosu için [Brief](https://) bölüm 3'teki konu başlıklarını takip edin.

## Lisans

Özel kullanım (`publish_to: 'none'`).
