# Progress — Kişisel Harcama Koçu

Proje geliştirme günlüğü: yapılan işler, alınan kararlar ve karşılaşılan hatalar.

**Proje başlangıcı:** Nisan 2026  
**Geliştirici:** Hatice Gazell

---

## Nisan 2026 — Fikir & planlama

| Tarih | Yapılan |
|-------|---------|
| Nisan (1. hafta) | Proje konusu netleştirildi: kişisel finans + AI koç |
| Nisan (2. hafta) | Hedef kitle ve problem tanımı yazıldı; PRD taslağı oluşturuldu |
| Nisan (3. hafta) | Flutter + Firebase teknoloji seçimi; ekran haritası çizildi |
| Nisan (4. hafta) | Yerel geliştirme ortamı kuruldu (Flutter SDK, Android Studio, Firebase projesi) |

**Kararlar:** Türkçe arayüz, TRY para birimi, offline-first yaklaşım, AI'ın çekirdek özellik olması.

---

## Mayıs 2026 — Hafta 1 (5–11)

| Tarih | Yapılan |
|-------|---------|
| 9 May | İlk ekran iskeletleri: Özet, Analiz, Takvim, Profil sekmeleri |
| 9–11 May | Drift veritabanı şeması, domain modeller, varsayılan kategoriler |

**Hatalar & çözümler:**

| Hata | Çözüm |
|------|-------|
| `flutter pub get` sonrası Drift codegen eksik | `dart run build_runner build --delete-conflicting-outputs` |
| Firebase `firebase_options.dart` yok | `flutterfire configure` çalıştırıldı |
| İlk giriş ekranında Google OAuth web client ID eksik | `AppConfig.webGoogleClientId` eklendi |

---

## Mayıs 2026 — Hafta 2 (12–18)

| Tarih | Yapılan |
|-------|---------|
| 16 May | Haftalık ilerleme: UI düzenlemeleri, navigasyon |
| 17 May | Ekranlar yeniden düzenlendi; profil avatar, login akışı iyileştirildi |
| 18 May | Gemini API entegrasyonu (ilk sürüm — istemci tarafında) |
| 18 May | API anahtarı güvenlik refactor: backend proxy'ye taşındı |
| 18 May | Login sorunları giderildi, profil avatar eklendi |

**Hatalar & çözümler:**

| Hata | Çözüm |
|------|-------|
| Google giriş Android'de `ApiException: 10` | Firebase Console'da SHA-1 fingerprint eklendi |
| E-posta girişinde Türkçe olmayan Firebase hataları | `AuthService` içinde hata eşleme tablosu |
| Gemini API key frontend'de hardcoded (güvenlik riski) | Node.js backend + `CoachApiService` REST çağrıları |
| PowerShell'de `&&` operatörü çalışmıyor | Komutlarda `;` kullanımı, `run_*.ps1` scriptleri |
| `assets/images/splash_logo.png` eksik | Logo PNG eklendi, `flutter_launcher_icons` yapılandırıldı |

---

## Mayıs 2026 — Hafta 3 (19–25)

| Tarih | Yapılan |
|-------|---------|
| 22 May | Repo yapısı düzenlendi: `frontend/`, `backend/`, `prodocs/` |
| 22 May | Backend Express API: `/health`, `/coach/chat`, `/coach/analyze` |
| 22 May | OpenRouter + Gemini fallback, Firebase token doğrulama |
| 22 May | `.gitignore` güncellendi; build çıktıları repodan çıkarıldı |
| 23–24 May | 4 ana sekme UI yenilemesi (özet, analiz, takvim, profil) |
| 24 May | Ortak header, bütçe kartı, AI insight, swipe-to-delete |
| 24 May | Auth onboarding (3 adımlı tanıtım) + sadeleştirilmiş giriş/kayıt |
| 24 May | Uygulama logosu (`splash_logo.png`) tüm ekranlara yayıldı |
| 24 May | Emülatör scriptleri: disk kontrolü, cold boot, pencere ortalama |
| 24 May | **Web responsive layout:** `HomeShellWeb` (sidebar), `HomeShellMobile` (mevcut mobil), breakpoint 900px |
| 24 May | **Drift web desteği:** `sqlite3.wasm` + `drift_worker.js`, `run_chrome.ps1` otomatik indirme |
| 24 May | **Tanıtım sitesi (Faz 1):** `go_router`, landing, hakkında, iletişim, gizlilik, navbar, `/giris` → `/uygulama` |
| 24 May | **Web UX (Faz 2):** adaptive dialog/formlar, koç yan paneli, işlem tablosu, klavye kısayolları, koç yükleme skeleton |
| 24 May | **SaaS görsel cilası (jüri):** canlı ürün önizlemesi, trust bar, metrik şeridi, jüri alıntısı, geniş auth paneli, `AppEmptyState`, Hakkında geliştirici kartı |
| 24 May | **Faz 3 — Cilalama + yayın hazırlığı:** `/uygulama/{ozet,analiz,takvim,profil}` URL senkronu, CSV export (web), SEO `index.html`, PWA `manifest.json`, `deploy_web.ps1`, `prodocs/DEPLOY.md`, `backend/render.yaml` |
| 24 May | **Web UX iyileştirmeleri:** `AppShellTopBar`, `WebAppSidebar` (ay özeti, hızlı erişim), profil menüden kaldırıldı, `/indir` QR sayfası, navbar linki |
| 24 May | **Brief uyumu:** Kök `render.yaml` → `backend/`; prodocs + README güncellendi (**mobil + web** ayrı bölümler) |
| 24 May | **Canlı yayın:** Backend Render + frontend Firebase Hosting deploy tamamlandı |
| 24 May | **Demo video:** 5 dk teslim videosu kaydedildi (problem → çözüm → mimari → demo → tech stack → kapanış) |

**Hatalar & çözümler:**

| Hata | Çözüm |
|------|-------|
| GitHub push reddedildi (`libflutter.so` > 100 MB) | `**/build/` gitignore; build klasörü git geçmişinden temizlendi |
| `firestore.rules` iç içe yanlış path (`users/.../users/...`) | Düz `coach_chat/{msgId}` alt koleksiyonu |
| Emülatör listede görünmüyor | `-gpu swiftshader_indirect` ile başlatma |
| `adb` PATH'te tanınmıyor | Script'lerde tam SDK yolu |
| Emülatör 1–2 dk sonra kapanıyor | C: diskinde ~2 GB boş alan; snapshot silme + disk temizliği |
| Emülatör penceresi ekranın üstüne yapışıyor | `emulator-user.ini` + Windows API ile ortalama |
| AI koç: "Backend'e ulaşılamadı" | Backend ayrı terminalde `npm run dev` + `adb reverse tcp:3001 tcp:3001` |
| `StatsHeader` const constructor hatası | `user` parametresi eklenince `const` kaldırıldı |
| Header'da geçici "HK" metni | `AppLogo` widget ile gerçek logo asset'i |
| AVD silip yeniden oluşturamama | Disk doluyken AVD oluşturma başarısız; önce boş alan açma |
| Web'de `dart:ffi is not available` derleme hatası | `drift/native.dart` kaldırıldı; `drift_flutter` + `DriftWebOptions` kullanıldı |
| `drift_worker.dart.js` GitHub'da bulunamadı | Doğru asset adı `drift_worker.js` (drift 2.31.0 release) |

**Alınan kararlar:**

| Karar | Gerekçe |
|-------|---------|
| Frontend / backend ayrımı | LLM anahtarı güvenliği, API'nin çoklu platforma hizmet vermesi |
| Finans bağlamı client'tan gönderilir | Backend'in Firestore okumasına gerek kalmaz; offline veri kullanılır |
| `--dart-define=BACKEND_URL` | Web ve mobil için farklı backend adresi |
| Onboarding + auth ayrımı | Tanıtım kaydırılır; giriş ekranı sade kalır |
| Chrome script (`run_chrome.ps1`) | Emülatör sorunlu ortamda hızlı test |
| Mobil/web shell ayrımı | Mobil UI bozulmadan web layout eklendi; ortak tab widget'ları paylaşılır |
| Drift WASM web | Web'de native SQLite yerine tarayıcı uyumlu Drift WebAssembly |

---

## Teslim durumu (Mayıs 2026)

| Görev | Durum |
|-------|-------|
| Backend canlı deploy (Render) | ✅ |
| Frontend web canlı deploy (Firebase Hosting) | ✅ |
| Demo videosu (max 5 dk) | ✅ |
| GitHub son commit + prodocs güncel | ✅ |
| Mobil + web uygulama çalışır durumda | ✅ |

## Post-MVP / iyileştirme (opsiyonel)

| Görev | Durum |
|-------|-------|
| `AppConstants` gerçek destek e-postası / gizlilik URL | Planlı |
| İşlem ve kategori düzenleme (v1.1) | Planlı |
| Gerçek Play Store / App Store mağaza yayını | Planlı |

---

## Metrikler (Mayıs 2026 sonu)

| Metrik | Değer |
|--------|-------|
| Frontend Dart dosyası | ~55+ |
| Backend modül | Express + Gemini servisi |
| API endpoint | 3 |
| Ana sekme | 4 |
| Zorunlu prodocs | 5 |
