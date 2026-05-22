# Tech Stack — Kişisel Harcama Koçu

## Mimari Özet

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
│ Auth + Firestore│
└─────────────────┘
         │
         │ Drift (SQLite) — offline-first
         ▼
┌─────────────────┐
│  Yerel Cihaz DB │
└─────────────────┘
```

Frontend ve backend **ayrı katmanlar** olarak tasarlandı. LLM çağrıları yalnızca backend üzerinden yapılır; API anahtarı istemcide tutulmaz.

---

## Frontend

| Teknoloji | Kullanım | Seçim Gerekçesi |
|-----------|----------|-----------------|
| **Flutter 3.x** | Cross-platform UI | Tek kod tabanı ile Android, iOS ve Web; hızlı MVP |
| **Dart ^3.5** | Uygulama dili | Flutter ekosistemi, güçlü tip sistemi |
| **Riverpod** | State management | Provider tabanlı, test edilebilir, reaktif stream'ler |
| **Drift (SQLite)** | Yerel veritabanı | Offline-first, tip güvenli SQL, hızlı okuma/yazma |
| **Firebase Auth** | Kimlik doğrulama | E-posta + Google OAuth, hazır altyapı |
| **Cloud Firestore** | Bulut senkronu | Kullanıcı bazlı koleksiyonlar, gerçek zamanlı yedek |
| **fl_chart** | Pasta grafik | Hafif, Material 3 uyumlu grafikler |
| **table_calendar** | Takvim UI | Aylık görünüm, gün seçimi |
| **Google Fonts** | Tipografi | Plus Jakarta Sans — modern fintech estetiği |
| **http** | Backend API client | Backend REST çağrıları |

---

## Backend

| Teknoloji | Kullanım | Seçim Gerekçesi |
|-----------|----------|-----------------|
| **Node.js 20** | Runtime | Hızlı geliştirme, geniş deploy desteği |
| **Express 4** | REST API | Minimal, esnek, iyi dokümante |
| **@google/generative-ai** | Gemini SDK | Resmi Google SDK, system instruction desteği |
| **firebase-admin** | Token doğrulama | Production'da Firebase ID token verify |
| **cors** | Cross-origin | Web client'tan güvenli erişim |
| **dotenv** | Yapılandırma | Geliştirme ortamı env yönetimi |

---

## Yapay Zeka (LLM)

| Özellik | Detay |
|---------|-------|
| **Model** | Google Gemini 2.0 Flash |
| **Entegrasyon** | Backend REST API (`POST /api/v1/coach/chat`) |
| **Çekirdek kullanım** | Finans koçu sohbeti + aylık harcama analizi |
| **Kişiselleştirme** | Kullanıcının gerçek gelir/gider/kategori verisi system prompt'a enjekte edilir |
| **Alternatifler değerlendirildi** | OpenRouter (çoklu model), OpenAI GPT-4o — Gemini seçildi: Türkçe kalitesi, ücretsiz tier, düşük latency |

---

## Deploy & DevOps

| Servis | Rol |
|--------|-----|
| **Firebase Hosting** | Web frontend (SPA) |
| **Render** | Backend API (free tier) |
| **Firebase Console** | Auth, Firestore, kurallar |

---

## Geliştirme Sürecinde AI Kullanımı

| Araç | Nasıl Kullanıldı |
|------|------------------|
| **Cursor IDE + Agent** | Kod üretimi, refactoring, dokümantasyon |
| **Gemini API** | Ürünün çekirdek AI özelliği (Finans Koçu) |
| **Claude/GPT (Cursor)** | Mimari kararlar, bug fix, test senaryoları |

### AI Destekli Geliştirici Kararları

1. **Monolitik Flutter → Frontend/Backend ayrımı:** Brief gereksinimine uygun olarak LLM çağrıları backend'e taşındı.
2. **Offline-first:** AI bağlamı için yerel Drift verisi kullanıldı; internet olmadan da kayıt yapılabilir.
3. **Financial context injection:** Generic chatbot yerine kullanıcının gerçek verisiyle kişiselleştirilmiş koç.
4. **Firebase token auth:** Production'da backend yalnızca doğrulanmış kullanıcılara yanıt verir.

---

## Test

| Tür | Araç | Kapsam |
|-----|------|--------|
| Statik analiz | `flutter analyze` | Frontend lint |
| Widget test | `flutter test` | Temel smoke test |
| Manuel QA | Android emülatör + Chrome | Auth, işlem, AI koç, sync |
