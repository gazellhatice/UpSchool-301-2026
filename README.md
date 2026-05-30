# Kişisel Harcama Koçu

> Yapay zeka destekli, Türkçe kişisel finans uygulaması — gelir/gider takibi, görsel analiz ve gerçek verilere dayalı **Finans Koçu**.

**Geliştirici:** Hatice Gazel  
**Başlangıç:** Nisan 2026 · **Sürüm:** 1.0.0  
**Platform:** Android · iOS · Web  
**Durum:** MVP tamamlandı · Canlı web + backend deploy · Demo video hazır

---

## Bu proje ne?

Kişisel Harcama Koçu, günlük gelir ve giderlerini hızlıca kaydetmeni, aylık bakiyeni ve harcama dağılımını görmeni sağlayan **mobil ve web** uygulamasıdır. Aynı hesapla telefondan veya tarayıcıdan giriş yapabilirsin; veriler Firebase üzerinden senkronize edilir. Mobilde veriler önce cihazda tutulur, web'de Drift WebAssembly ile tarayıcıda saklanır.

Uygulamanın ayırt edici tarafı **Finans Koçu**: kullanıcının kendi kayıtlı harcama verilerini okuyarak bütçe, alışkanlık ve hedef konularında kişiselleştirilmiş yanıtlar üretir. Hazır cevaplı bir chatbot değil; her oturumda o ayki gelir, gider ve kategori dağılımı backend'e bağlam olarak gönderilir.

Hedef kitle: Türkiye'deki genç profesyoneller, öğrenciler ve serbest çalışanlar. Arayüz Türkçe, para birimi ₺.

---

## Özellikler

> **Mobil ve web birlikte:** Aynı Flutter projesi, aynı Firebase hesabı, aynı dört sekme (Özet, Analiz, Takvim, Profil). Web'e ek olarak tanıtım sitesi ve geniş ekran sidebar vardır; **mobil uygulama ayrı shell ile korunur.**

### Giriş ve hesap
- E-posta / şifre ile kayıt ve giriş
- Google ile oturum açma (mobil + web)
- Şifre sıfırlama
- İlk açılışta 3 adımlı tanıtım (atlanabilir), ardından giriş/kayıt ekranı
- **Aynı hesap, tüm platformlar:** Mobilde kaydettiğin işlemler web'de de görünür (Firestore senkronu)

### Dört ana sekme (mobil + web)

| Sekme | İçerik |
|-------|--------|
| **Özet** | Aylık gelir/gider, net bakiye, bütçe kullanım oranı, son işlemler, 7 günlük grafik, AI özet kartı |
| **Analiz** | Pasta grafik, kategori kırılımı, aylık trend, otomatik içgörüler |
| **Takvim** | Ay görünümü, günlük işlem listesi, ısı haritası |
| **Profil** | Tema, kategori yönetimi, manuel senkron, gizlilik metni, çıkış |

### Finans Koçu (AI)
- Sohbet: bütçe soruları, harcama alışkanlığı, hedef belirleme
- Tek tıkla aylık AI analiz özeti
- LLM çağrıları yalnızca backend üzerinden; API anahtarı istemcide tutulmaz

### Mobil (Android / iOS)
- **Kabuk:** `home_shell_mobile.dart` — alt **4 sekmeli** gezinme (Özet, Analiz, Takvim, Profil)
- **FAB:** Finans Koçu + İşlem ekle (Özet ve Takvim'de)
- **Offline-first:** Drift SQLite; uçak modunda işlem, sonra Firestore senkronu
- **Google giriş:** Native Sign-In (Firebase SHA-1)
- **Çalıştırma:** `frontend/run_emulator.ps1` (emülatör + `adb reverse` ile backend)

### Web (tarayıcı)
- **≥900px genişlik:** Sol sidebar navigasyon, ortalanmış içerik (max 1200px), Finans Koçu ve İşlem ekle butonları sidebar'da
- **<900px genişlik:** Mobil düzen (alt tab bar + FAB) — telefon ve dar tarayıcı penceresi
- Tek Flutter kod tabanı; mobil kod ayrı shell dosyasında korunur (`home_shell_mobile.dart` / `home_shell_web.dart`)
- **Tanıtım sitesi:** `/`, `/hakkimizda`, `/iletisim`, `/gizlilik`, `/indir`, `/giris`
- **Uygulama URL'leri:** `/uygulama/ozet`, `/uygulama/analiz`, `/uygulama/takvim`, `/uygulama/profil` (yenilemede sekme korunur)
- **Geniş web sidebar:** Menü (3 sekme), Finans Koçu, aylık özet, hızlı erişim; profil alttaki kullanıcı kartından
- **Web:** CSV indirme, PWA manifest, klavye kısayolları (`N`, `K`, `1–4`, `Esc`)

### Veri modeli
- **Offline-first (mobil):** Drift (SQLite) ile yerel kayıt
- **Web:** Drift WebAssembly (`sqlite3.wasm` + `drift_worker.js`) ile tarayıcıda yerel DB
- **Bulut senkronu:** Firebase Firestore — platformlar arası aynı hesap
- Uçak modunda (mobil) işlem eklenebilir; bağlantı gelince senkron devam eder

---

## Mimari

Frontend (Flutter) ve backend (Node.js Express) birbirinden ayrıdır. Backend, LLM isteklerini karşılayan REST API katmanıdır.

```mermaid
flowchart LR
  subgraph client [Frontend]
    UI[Ekranlar]
    Drift[(Drift SQLite)]
    UI --> Drift
  end

  subgraph cloud [Firebase]
    Auth[Authentication]
    FS[Firestore]
  end

  subgraph server [Backend]
    API[Express REST]
    LLM[Gemini / OpenRouter]
    API --> LLM
  end

  UI --> Auth
  UI --> FS
  Drift <-->|senkron| FS
  UI -->|HTTPS| API
```

**Koç akışı:** Kullanıcı soru sorar → frontend yerel veriden ay özeti oluşturur → backend LLM'e gönderir → yanıt ekranda gösterilir, sohbet geçmişi Firestore'a yazılır.

---

## Teknolojiler

| Katman | Kullanılan |
|--------|------------|
| Frontend | Flutter · Dart · Riverpod · Drift · Firebase · fl_chart |
| Backend | Node.js · Express · Gemini SDK · OpenRouter · firebase-admin |
| AI | Gemini 2.0 Flash, OpenRouter fallback |

Detay: [prodocs/tech-stack.md](prodocs/tech-stack.md)

---

## Repo yapısı (Future Talent brief)

Brief’e uygun kök dizin — yalnızca şu öğeler repoda tutulur:

```
├── frontend/          Flutter — mobil (Android/iOS) + web arayüzü
├── backend/           Node.js REST API + render.yaml (Render deploy)
├── prodocs/           PRD, tech-stack, Plan, DesignSystem, Progress, DEPLOY
├── README.md          Bu dosya (onepager)
├── .gitignore
└── .env.example
```

| Klasör | İçerik |
|--------|--------|
| `frontend/` | **Mobil** (Android/iOS shell) + **web** (sidebar, marketing, WASM) — tek Flutter kodu |
| `backend/` | Express API, AI koç, `backend/render.yaml` |
| `prodocs/` | Zorunlu dokümanlar: `PRD.md`, `tech-stack.md`, `Plan.md`, `DesignSystem.md`, `Progress.md` |

---

## Projeyi çalıştırma

**Backend** (ayrı terminal):
```powershell
cd backend
copy .env.example .env
npm install
npm run dev
```

**Frontend (mobil + web):**
```powershell
cd frontend
flutter pub get
.\run_chrome.ps1    # Web (Chrome) — wasm dosyalarını otomatik indirir
.\run_emulator.ps1 # Android emülatör
```

`run_chrome.ps1` ilk çalıştırmada `web/sqlite3.wasm` ve `web/drift_worker.js` dosyalarını indirir (Drift web veritabanı için gerekli).

Finans Koçu için backend'in `http://localhost:3001` adresinde açık olması gerekir. Android emülatörde `frontend/run_emulator.ps1` script'i `adb reverse` işlemini otomatik yapar.

**Web canlı deploy:** Adım adım rehber → [prodocs/DEPLOY.md](prodocs/DEPLOY.md)

```powershell
cd frontend
.\deploy_web.ps1   # Render API URL'sini sorar, build + firebase deploy
```

Firebase ilk kurulum: `frontend/` içinde `flutterfire configure`, ardından `firebase deploy --only firestore:rules`.

---

## Teslim (Future Talent 2026)

| Öğe | Durum |
|-----|--------|
| GitHub repo (son commit) | ✅ |
| Mobil + web uygulama | ✅ |
| Backend canlı (Render) | ✅ — `prodocs/DEPLOY.md` |
| Web canlı (Firebase Hosting) | ✅ — `frontend/deploy_web.ps1` |
| Demo video (≤5 dk) | ✅ — brief akışına uygun |
| Zorunlu prodocs | ✅ — `prodocs/` |

Canlı URL ve video linkini teslim formuna yazarken kendi Render / Firebase / Loom adreslerini ekle.

---

## API (backend)

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/health` | Sağlık kontrolü |
| POST | `/api/v1/coach/chat` | Finans koçu sohbeti |
| POST | `/api/v1/coach/analyze` | Aylık AI özeti |

Sözleşme: [prodocs/api-contract.md](prodocs/api-contract.md)

---

## Dokümantasyon

### Zorunlu (brief)

| Dosya | Konu |
|-------|------|
| [prodocs/PRD.md](prodocs/PRD.md) | Problem, hedef kitle, mobil + web özellikler |
| [prodocs/tech-stack.md](prodocs/tech-stack.md) | Teknolojiler, AI kullanımı, web/mobil ayrımı |
| [prodocs/Plan.md](prodocs/Plan.md) | Fazlar, kullanıcı hikâyeleri, web pazarlama fazı |
| [prodocs/DesignSystem.md](prodocs/DesignSystem.md) | Renk, tipografi, mobil + web bileşenler |
| [prodocs/Progress.md](prodocs/Progress.md) | Geliştirme günlüğü |

### Ek referans

| Dosya | Konu |
|-------|------|
| [prodocs/DEPLOY.md](prodocs/DEPLOY.md) | Canlı yayın (Firebase Hosting + Render) |
| [prodocs/architecture.md](prodocs/architecture.md) | Katmanlar, URL haritası, Firestore |
| [prodocs/mvp-scope.md](prodocs/mvp-scope.md) | MVP kapsamı ve kabul kriterleri |
| [prodocs/api-contract.md](prodocs/api-contract.md) | Backend API sözleşmesi |
| [backend/render.yaml](backend/render.yaml) | Render.com deploy şablonu |

---

## Güvenlik

API anahtarları ve `.env` dosyaları repoya eklenmez. Şablon: `.env.example` ve `backend/.env.example`. Firestore kuralları kullanıcı bazlı erişimle sınırlandırılmıştır.
