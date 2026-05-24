# Tech Stack — Kişisel Harcama Koçu

## Mimari özet

```
┌─────────────────┐     HTTPS/REST      ┌──────────────────┐     Gemini API    ┌─────────────┐
│  Flutter Client │ ◄──────────────────► │  Node.js Backend │ ◄───────────────► │ Google LLM  │
│  (frontend/)    │   Firebase ID Token  │  (backend/)      │                   │ gemini-2.0  │
└────────┬────────┘                      └──────────────────┘                   └─────────────┘
         │
         │ Firebase Auth + Firestore
         ▼
┌─────────────────┐
│ Firebase Cloud  │
└─────────────────┘
         │
         │ Drift — offline-first (mobil: SQLite, web: WASM)
         ▼
┌─────────────────┐
│  Yerel DB       │
│  mobil / web    │
└─────────────────┘
```

Frontend ve backend **ayrı katmanlar** olarak tasarlandı. LLM çağrıları yalnızca backend üzerinden yapılır.

---

## Frontend

| Teknoloji | Kullanım | Gerekçe |
|-----------|----------|---------|
| Flutter 3.x | Cross-platform UI | Android, iOS, Web tek kod tabanı |
| Dart ^3.5 | Uygulama dili | Tip güvenliği, Flutter ekosistemi |
| Riverpod | State management | Reaktif, test edilebilir |
| Drift (SQLite / WASM) | Yerel DB | Mobil: dosya tabanlı SQLite; Web: `sqlite3.wasm` + `drift_worker.js` |
| drift_flutter | DB bağlantısı | Platforma göre native veya web executor |
| Firebase Auth | Kimlik doğrulama | E-posta + Google OAuth |
| Cloud Firestore | Bulut senkronu | Kullanıcı bazlı koleksiyonlar |
| fl_chart | Grafikler | Pasta grafik, trend |
| table_calendar | Takvim | Günlük işlem görünümü |
| Google Fonts | Tipografi | Plus Jakarta Sans |
| http | Backend client | REST API çağrıları |

### Web layout

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| Breakpoint | `responsive_breakpoints.dart` | ≥900px → web, altında mobil |
| Mobil shell | `home_shell_mobile.dart` | Alt tab bar + FAB (değiştirilmedi) |
| Web shell | `home_shell_web.dart` | Sol sidebar, max 1200px içerik |
| Router | `home_shell.dart` | Ekran genişliğine göre shell seçimi |

---

## Backend

| Teknoloji | Kullanım | Gerekçe |
|-----------|----------|---------|
| Node.js 20 | Runtime | Hızlı geliştirme, geniş deploy desteği |
| Express 4 | REST API | Minimal, esnek |
| @google/generative-ai | Gemini SDK | Resmi Google SDK |
| firebase-admin | Token doğrulama | Production auth |
| cors | Cross-origin | Web client erişimi |
| dotenv | Yapılandırma | Ortam değişkenleri |

---

## Yapay zeka (LLM)

| Özellik | Detay |
|---------|-------|
| Model | Google Gemini 2.0 Flash |
| Entegrasyon | Backend REST (`POST /api/v1/coach/chat`) |
| Kullanım | Finans koçu sohbeti + aylık analiz |
| Kişiselleştirme | Kullanıcının gerçek gelir/gider/kategori verisi prompt'a eklenir |
| Değerlendirilen alternatifler | OpenRouter, OpenAI GPT-4o — Gemini: Türkçe kalitesi, maliyet |

---

## Deploy

| Servis | Rol |
|--------|-----|
| Firebase Hosting | Web frontend (Flutter build/web) |
| Render | Backend API |
| Firebase Console | Auth, Firestore, kurallar |

---

## Geliştirme sürecinde AI kullanımı

| Araç | Kullanım |
|------|----------|
| Cursor IDE + Agent | Kod üretimi, refactoring, dokümantasyon |
| Gemini API | Ürünün çekirdek AI özelliği (Finans Koçu) |
| Cursor AI modelleri | Mimari kararlar, hata ayıklama, UI iyileştirme |

### Önemli teknik kararlar

1. **Frontend/backend ayrımı:** LLM anahtarı ve iş mantığı sunucuda.
2. **Offline-first:** Kayıt internetsiz yapılır; AI için bağlantı gerekir.
3. **Financial context injection:** Generic chatbot yerine kişisel veriye dayalı koç.
4. **Firebase token auth:** Backend yalnızca doğrulanmış kullanıcıya yanıt verir.
5. **Responsive web shell:** Mobil kod korunarak web için ayrı layout; aynı auth ve Firestore senkronu.

---

## Test

| Tür | Araç |
|-----|------|
| Statik analiz | `flutter analyze` |
| Widget test | `flutter test` |
| Manuel QA | Android emülatör, Chrome (web responsive) |
