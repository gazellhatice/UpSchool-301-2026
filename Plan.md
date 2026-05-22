# Plan — Kişisel Harcama Koçu

PRD'den türetilmiş teknik uygulama adımları ve kullanıcı hikâyeleri.

---

## Faz 0 — Proje Altyapısı

| # | Kullanıcı Hikâyesi | Teknik Adım | Durum |
|---|-------------------|-------------|-------|
| 0.1 | Geliştirici olarak monorepo yapısında çalışmak istiyorum | `frontend/`, `backend/`, `prodocs/` klasör yapısı | ✅ |
| 0.2 | Geliştirici olarak dokümantasyonu takip etmek istiyorum | PRD, tech-stack, Plan, DesignSystem, Progress | ✅ |
| 0.3 | Geliştirici olarak gizli anahtarları güvenle yönetmek istiyorum | `.env.example`, `.gitignore`, backend env | ✅ |

---

## Faz 1 — Kimlik Doğrulama (US-01, US-02)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 1.1 | Firebase projesi + FlutterFire configure | `firebase_options.dart` | ✅ |
| 1.2 | AuthService: e-posta kayıt/giriş | `auth_service.dart` | ✅ |
| 1.3 | Google Sign-In (Android/Web) | `auth_service.dart`, `app_config.dart` | ✅ |
| 1.4 | AuthGate + Splash akışı | `auth_gate.dart`, `splash_screen.dart` | ✅ |
| 1.5 | Şifre sıfırlama e-postası | `auth_service.dart` | ✅ |

---

## Faz 2 — Finans Verisi (US-03, US-07, US-08)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 2.1 | Drift şema: categories, transactions | `app_database.dart` | ✅ |
| 2.2 | Domain modeller + mapper'lar | `domain/models/`, `finance_mappers.dart` | ✅ |
| 2.3 | FinanceRepository CRUD + sync | `finance_repository.dart` | ✅ |
| 2.4 | Varsayılan 8 kategori seed | `default_categories.dart` | ✅ |
| 2.5 | İşlem ekleme formu (sheet) | `transaction_form_sheet.dart` | ✅ |
| 2.6 | Özel kategori ekleme | `add_category_sheet.dart` | ✅ |
| 2.7 | Firestore push/pull + offline queue | `finance_repository.dart` | ✅ |

---

## Faz 3 — Dashboard & Görselleştirme (US-04, US-05, US-06)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 3.1 | HomeShell + 4 sekme navigasyonu | `home_shell.dart` | ✅ |
| 3.2 | Özet: bakiye, gelir/gider, son işlemler | `dashboard_tab.dart` | ✅ |
| 3.3 | Ay seçici widget | `month_selector.dart` | ✅ |
| 3.4 | Analiz: pasta grafik + kategori listesi | `stats_tab.dart` | ✅ |
| 3.5 | Takvim: günlük işlem listesi | `calendar_tab.dart` | ✅ |
| 3.6 | Profil/ayarlar: tema, sync, çıkış | `settings_tab.dart` | ✅ |

---

## Faz 4 — AI Finans Koçu (Brief: LLM çekirdek özellik)

| # | Adım | Dosyalar | Durum |
|---|------|----------|-------|
| 4.1 | Backend Express API kurulumu | `backend/src/index.js` | ✅ |
| 4.2 | Gemini servisi + system prompt | `backend/src/services/gemini.js` | ✅ |
| 4.3 | POST /api/v1/coach/chat endpoint | `backend/src/routes/coach.js` | ✅ |
| 4.4 | POST /api/v1/coach/analyze endpoint | `backend/src/routes/coach.js` | ✅ |
| 4.5 | Firebase token middleware | `backend/src/middleware/auth.js` | ✅ |
| 4.6 | Frontend CoachApiService | `coach_api_service.dart` | ✅ |
| 4.7 | Finans bağlamı builder | `financial_context_builder.dart` | ✅ |
| 4.8 | Koç sohbet ekranı (backend'e bağlı) | `coach_chat_screen.dart` | ✅ |
| 4.9 | Dashboard AI Finans Özeti kartı | `coach_insight_card.dart` | ✅ |
| 4.10 | Sohbet geçmişi Firestore'da | `users/{uid}/coach_chat` | ✅ |

---

## Faz 5 — Güvenlik & Deploy (Brief: canlıya alma)

| # | Adım | Durum |
|---|------|-------|
| 5.1 | API anahtarını frontend'den kaldır | ✅ |
| 5.2 | Firestore security rules düzelt | ✅ |
| 5.3 | Firebase Hosting yapılandırması | ✅ |
| 5.4 | Render backend deploy config | ✅ |
| 5.5 | Backend canlı deploy | ⏳ Kullanıcı Render'da deploy edecek |
| 5.6 | Frontend web canlı deploy | ⏳ Kullanıcı Firebase Hosting'de deploy edecek |
| 5.7 | Demo video (5 dk) | ⏳ Kullanıcı çekecek |

---

## Faz 6 — Yayın Hazırlığı

| # | Adım | Durum |
|---|------|-------|
| 6.1 | Gizlilik politikası ekranı | ✅ |
| 6.2 | AppConstants: destek e-postası, gizlilik URL | ⏳ Gerçek değerlerle güncelle |
| 6.3 | Android release imzalama | ⏳ Play Store için |
| 6.4 | Uygulama ikonu (`flutter_launcher_icons`) | ⏳ assets/images/splash_logo.png gerekli |

---

## Bağımlılık Grafiği

```
Faz 0 → Faz 1 → Faz 2 → Faz 3 → Faz 4 → Faz 5 → Faz 6
                  └──────────────────────────────┘
                        (AI koç Faz 2 verisine bağlı)
```

---

## Riskler

| Risk | Mitigasyon |
|------|------------|
| Render free tier cold start | Health check + demo öncesi ısıtma |
| Gemini API quota | Flash model, maxOutputTokens limit |
| Web CORS | CORS_ORIGINS env ile frontend URL ekle |
| Eksik splash_logo asset | PNG ekle veya flutter_launcher_icons çalıştır |
