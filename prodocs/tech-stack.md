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
| go_router | URL routing (web) | Tanıtım + `/uygulama/*` deep link |
| qr_flutter | QR kod (indirme sayfası) | `/indir` sayfasında mobil yönlendirme |

### Mobil layout (Android / iOS — birincil ürün)

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| Mobil shell | `home_shell_mobile.dart` | Alt 4 sekmeli `NavigationBar` + FAB'lar |
| Yerel DB | `app_database.dart` | Drift **SQLite** (native dosya) |
| Offline | `finance_repository.dart` | `synced: false` kuyruk, bağlantı gelince push |
| Google Sign-In | `auth_service.dart` | Native OAuth; Firebase SHA-1 |
| Emülatör | `run_emulator.ps1` | AVD başlatma, `adb reverse tcp:3001` |
| Sekmeler | `dashboard/`, `stats/`, `calendar/`, `settings_tab.dart` | Mobil + dar web'de ortak |

Mobil kod **ayrı shell dosyasında korunur**; web geniş layout eklenirken mobil UI değiştirilmedi.

### Web — tanıtım sitesi (yalnızca tarayıcı)

| Bileşen | Konum | Açıklama |
|---------|-------|----------|
| Marketing shell | `marketing_shell.dart` | Navbar + footer + child |
| Landing | `landing_page.dart` | Hero, trust bar, ürün önizlemesi |
| İndir | `download_page.dart` | QR + mağaza bağlantıları |
| Auth layout | `auth_route_page.dart` | Geniş ekranda marka paneli |

### Web — uygulama kabuğu (giriş sonrası)

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| Breakpoint | `responsive_breakpoints.dart` | ≥900px → web, altında mobil |
| Mobil shell | `home_shell_mobile.dart` | **Tüm telefonlar** + dar tarayıcı (<900px) |
| Web shell | `home_shell_web.dart` | Geniş tarayıcı (≥900px) — sidebar |
| Üst çubuk | `app_shell_top_bar.dart` | Breadcrumb, ay seçici, koç, profil |
| Router | `home_shell.dart` | Ekran genişliğine göre shell seçimi |
| URL senkron | `app_navigation.dart` | Sekme ↔ `/uygulama/*` (web) |

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
| Google Play / App Store | Mobil dağıtım (`/indir` QR + demo mağaza linkleri) |
| Firebase Hosting | Web frontend canlı (`build/web`) — ✅ |
| Render | Backend API canlı (`backend/render.yaml`) — ✅ |
| Firebase Console | Auth, Firestore, kurallar — **mobil + web ortak** |

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
