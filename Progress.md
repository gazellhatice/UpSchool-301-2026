# Progress — Kişisel Harcama Koçu

Geliştirme günlüğü: yapılan işler, alınan kararlar ve karşılaşılan hatalar.

---

## 2026-05-22 — Bitirme Projesi Brief Uyumu

### Yapılanlar

1. **Repo yapısı brief'e göre yeniden düzenlendi**
   - Flutter uygulaması `frontend/` altına taşındı
   - `backend/` Node.js Express API oluşturuldu
   - `prodocs/` AI ajan referans klasörü eklendi

2. **Backend API (ayrı katman)**
   - `POST /api/v1/coach/chat` — Gemini sohbet
   - `POST /api/v1/coach/analyze` — aylık AI finans özeti
   - `GET /health` — sağlık kontrolü
   - Firebase ID token doğrulama middleware
   - Render deploy config (`render.yaml`, `Dockerfile`)

3. **Frontend — AI entegrasyonu güvenli hale getirildi**
   - Hardcoded Gemini API anahtarı kaldırıldı (güvenlik riski giderildi)
   - `CoachApiService` backend REST çağrıları yapıyor
   - `financial_context_builder.dart` — kullanıcının gerçek verisi LLM'e aktarılıyor
   - Dashboard'a `CoachInsightCard` (AI Finans Özeti) eklendi
   - Koç sohbeti finans verisi bağlamıyla kişiselleştirildi

4. **Dokümantasyon**
   - `README.md` — deploy rehberi
   - `tech-stack.md`, `Plan.md`, `DesignSystem.md`, `Progress.md`
   - `.env.example` (kök + backend)
   - `PRD.md` AI koç bölümüyle güncellenecek

5. **Firebase**
   - `firestore.rules` — `coach_chat` koleksiyonu düzeltildi (iç içe path hatası giderildi)
   - `firebase.json` — Hosting yapılandırması (`frontend/build/web`)

### Alınan Kararlar

| Karar | Gerekçe |
|-------|---------|
| Node.js + Express backend | Hızlı MVP, Render free tier, Gemini SDK desteği |
| Gemini 2.0 Flash | Düşük maliyet, hızlı yanıt, iyi Türkçe |
| Finans bağlamı client'tan gönderilir | Backend Firestore'a erişmek zorunda kalmaz; offline veri kullanılabilir |
| `--dart-define=BACKEND_URL` | Build-time yapılandırma; web ve mobil için farklı URL |
| Monorepo (frontend + backend) | Brief klasör yapısı gereksinimi |

### Karşılaşılan Hatalar & Çözümler

| Hata | Çözüm |
|------|-------|
| Gemini API key frontend'de hardcoded | Backend proxy'ye taşındı |
| `firestore.rules` iç içe `users/{userId}/users/...` path | Düz `coach_chat/{msgId}` alt koleksiyonu |
| PowerShell `&&` operatörü desteklenmiyor | `;` ile komut zinciri |
| `assets/images/splash_logo.png` eksik | pubspec referansı var; kullanıcı PNG eklemeli |

### Sırada

- [ ] Backend Render'da deploy
- [ ] Frontend web Firebase Hosting'de deploy
- [ ] `AppConstants` gerçek destek e-postası / gizlilik URL
- [ ] Demo video çekimi (kullanıcı)
- [ ] Teslim formu (14 Haziran 2026)

---

## Önceki Geliştirme (MVP)

| Tarih | İş |
|-------|-----|
| 2026-05 | Flutter proje iskeleti, Firebase Auth |
| 2026-05 | Drift DB + Firestore sync |
| 2026-05 | 4 sekme UI: Özet, Analiz, Takvim, Profil |
| 2026-05 | İlk koç sohbeti (doğrudan Gemini — refactor edildi) |
| 2026-05 | Gizlilik politikası ekranı, confirm dialog, month selector |

---

## Metrikler

| Metrik | Değer |
|--------|-------|
| Frontend Dart dosyası | ~42 |
| Backend JS dosyası | 4 |
| API endpoint | 3 |
| Doküman | 7 |
