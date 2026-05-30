# Plan — Kişisel Harcama Koçu

[PRD.md](PRD.md) dosyasından türetilmiş teknik adımlar ve kullanıcı hikâyeleri.

> **Not:** Proje **mobil (Android/iOS) + web** birlikte geliştirildi. Faz 1–4 ve Faz 3 mobil + ortak özelliklerdir. **Faz 3b** yalnızca web'e eklenen tanıtım sitesi ve geniş ekran kabuğudur; mobil shell (`home_shell_mobile.dart`) korunmuştur.

---

## Faz 0 — Proje altyapısı

| # | Adım | Durum |
|---|------|-------|
| 0.1 | `frontend/`, `backend/`, `prodocs/` klasör yapısı | ✅ |
| 0.2 | PRD, tech-stack, Plan, DesignSystem, Progress dokümanları | ✅ |
| 0.3 | `.env.example`, `.gitignore`, gizli anahtar yönetimi | ✅ |

---

## Faz 1 — Kimlik doğrulama (US-01, US-02)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 1.1 | Firebase + FlutterFire | `firebase_options.dart` | ✅ |
| 1.2 | E-posta kayıt / giriş | `auth_service.dart` | ✅ |
| 1.3 | Google Sign-In | `auth_service.dart` | ✅ |
| 1.4 | Splash, onboarding, AuthGate | `auth_*.dart` | ✅ |
| 1.5 | Şifre sıfırlama | `auth_service.dart` | ✅ |

---

## Faz 2 — Finans verisi (US-03, US-07, US-08)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 2.1 | Drift şema | `app_database.dart` | ✅ |
| 2.1b | Drift web (WASM) bağlantısı | `app_database.dart`, `web/sqlite3.wasm`, `web/drift_worker.js` | ✅ |
| 2.2 | Domain modeller | `domain/models/` | ✅ |
| 2.3 | Repository + sync | `finance_repository.dart` | ✅ |
| 2.4 | Varsayılan kategoriler | `default_categories.dart` | ✅ |
| 2.5 | İşlem formu | `transaction_form_sheet.dart` | ✅ |
| 2.6 | Özel kategori | `add_category_sheet.dart` | ✅ |

---

## Faz 3 — Dashboard & görselleştirme (US-04, US-05, US-06)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 3.1 | 4 sekme shell (mobil + web router) | `home_shell.dart`, `home_shell_mobile.dart`, `home_shell_web.dart` | ✅ |
| 3.1b | Responsive breakpoint | `responsive_breakpoints.dart` | ✅ |
| 3.2 | Özet sekmesi | `dashboard/` | ✅ |
| 3.3 | Analiz sekmesi | `stats/` | ✅ |
| 3.4 | Takvim sekmesi | `calendar/` | ✅ |
| 3.5 | Profil sekmesi | `profile/`, `settings_tab.dart` | ✅ |
| 3.6 | Ortak header | `app_screen_header.dart` | ✅ |

---

## Faz 4 — AI Finans Koçu (US-11, US-12)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 4.1 | Express API | `backend/src/index.js` | ✅ |
| 4.2 | Gemini servisi | `backend/src/services/gemini.js` | ✅ |
| 4.3 | `/api/v1/coach/chat` | `backend/src/routes/coach.js` | ✅ |
| 4.4 | `/api/v1/coach/analyze` | `backend/src/routes/coach.js` | ✅ |
| 4.5 | Firebase token middleware | `backend/src/middleware/auth.js` | ✅ |
| 4.6 | Frontend API client | `coach_api_service.dart` | ✅ |
| 4.7 | Finans bağlamı | `financial_context_builder.dart` | ✅ |
| 4.8 | Koç sohbet ekranı | `coach_chat_screen.dart` | ✅ |
| 4.9 | Dashboard AI kartı | `coach_insight_card.dart` | ✅ |

---

## Faz 5 — Güvenlik & deploy

| # | Adım | Durum |
|---|------|-------|
| 5.1 | API anahtarını frontend'den kaldır | ✅ |
| 5.2 | Firestore security rules | ✅ |
| 5.3 | Firebase Hosting yapılandırması | ✅ |
| 5.3b | Web Drift WASM asset'leri + `run_chrome.ps1` | ✅ |
| 5.3c | Mobil geliştirme scriptleri (`run_emulator.ps1`, `adb reverse`) | ✅ |
| 5.4 | Render backend config (`backend/render.yaml`) | ✅ |
| 5.5 | Backend canlı deploy (Render) | ✅ |
| 5.6 | Frontend **web** canlı deploy (`deploy_web.ps1`, Firebase Hosting) | ✅ |
| 5.7 | Android APK / Play Store (opsiyonel — `/indir` demo linkleri) | ✅ |

---

## Faz 3b — Web ekleri (mobile dokunulmadı) (US-13 … US-17)

Mobil Faz 3 tamamlandıktan **sonra** eklenen web katmanı; `home_shell_mobile.dart` ve 4 sekmeli alt bar aynen durur.

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 3b.1 | `go_router` + route sabitleri | `app_routes.dart`, `router_provider.dart` | ✅ |
| 3b.2 | Marketing shell, navbar, footer | `marketing_*.dart` | ✅ |
| 3b.3 | Landing, Hakkında, İletişim, Gizlilik | `landing_page.dart`, `about_page.dart`, … | ✅ |
| 3b.4 | Mobil indirme sayfası (QR) | `download_page.dart`, `/indir` | ✅ |
| 3b.5 | Auth sayfa layout (web panel) | `auth_route_page.dart`, `auth_brand_panel.dart` | ✅ |
| 3b.6 | Web shell üst çubuk + sidebar | `app_shell_top_bar.dart`, `web_app_sidebar.dart` | ✅ |
| 3b.7 | URL ↔ sekme senkronu | `app_navigation.dart` | ✅ |
| 3b.8 | CSV export (web) | `csv_export*.dart`, Profil | ✅ |
| 3b.9 | SEO + PWA | `web/index.html`, `manifest.json` | ✅ |
| 3b.10 | Koç yan paneli, klavye kısayolları | `coach_panel_provider.dart`, `app_keyboard_shortcuts.dart` | ✅ |

---

## Faz 6 — Yayın hazırlığı

| # | Adım | Durum |
|---|------|-------|
| 6.1 | Gizlilik politikası ekranı | ✅ |
| 6.2 | Uygulama ikonu / splash logo | ✅ |
| 6.3 | Demo video (≤5 dk, Loom/YouTube) | ✅ |
| 6.4 | Android release imzalama (opsiyonel) | ✅ |

---

## Bağımlılık sırası

```
Faz 0 → Faz 1 → Faz 2 → Faz 3 (mobil+ortak UI) → Faz 4 → Faz 3b (web ek) → Faz 5 → Faz 6
                              └──────────────────────────────┘
                                    (AI koç, Faz 2 verisine bağlı)
```
