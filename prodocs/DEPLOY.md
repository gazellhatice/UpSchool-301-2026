# Canlı yayın (Deploy)

Bitirme teslimi için **canlı web URL** yeterlidir. Önerilen mimari:

| Parça | Servis | Not |
|-------|--------|-----|
| Frontend (Flutter web) | Firebase Hosting | `frontend/firebase.json` → `build/web` |
| Backend (Express API) | Render free tier | `render.yaml` veya manuel Web Service |
| Auth + veri | Firebase | Authorized domains + Firestore |

---

## 1. Backend (Render)

1. [render.com](https://render.com) → **New Web Service** → repo bağla, **Root Directory:** `backend`
2. **Build:** `npm install` · **Start:** `npm start`
3. Ortam değişkenleri (`.env.example` referans):

| Değişken | Örnek |
|----------|--------|
| `AI_PROVIDER` | `openrouter` |
| `OPENROUTER_API_KEY` | (anahtarın) |
| `OPENROUTER_MODEL` | `openrouter/free` |
| `CORS_ORIGINS` | `https://PROJE-ID.web.app,https://PROJE-ID.firebaseapp.com` |
| `NODE_ENV` | `production` |

4. Deploy sonrası URL: `https://kisisel-harcama-kocu-api.onrender.com` (örnek)

**Not:** Free tier uyuyunca ilk koç isteği 20–30 sn sürebilir.

---

## 2. Firebase — Auth domain

Firebase Console → **Authentication** → **Settings** → **Authorized domains**

- `localhost` (geliştirme)
- `PROJE-ID.web.app`
- `PROJE-ID.firebaseapp.com`

---

## 3. Frontend build + Hosting

```powershell
cd frontend

# Geliştirme
.\run_chrome.ps1

# Canlı build + deploy (script)
.\deploy_web.ps1
# Backend URL sorulur — Render API adresini gir
```

Manuel build:

```powershell
flutter build web --release --no-tree-shake-icons `
  --dart-define=BACKEND_URL=https://YOUR-API.onrender.com

firebase deploy --only hosting
```

---

## 4. Kontrol listesi

- [ ] Landing `/` açılıyor
- [ ] `/giris` → kayıt/giriş → `/uygulama/ozet`
- [ ] Sekme URL’leri: `/uygulama/analiz`, `/takvim`, `/profil` (yenilemede sekme korunur)
- [ ] Google giriş (web) çalışıyor
- [ ] Finans Koçu cevap veriyor (`CORS_ORIGINS` doğru)
- [ ] Profil → CSV indir (web)
- [ ] Demo video: landing → kayıt → işlem → koç

---

## 5. Demo video senaryosu (≤5 dk)

1. Ana sayfa hero + özellikler
2. Kayıt / giriş
3. İşlem ekle (dialog)
4. Analiz sekmesi
5. Finans Koçu (yan panel veya tam ekran)
6. Profil → CSV indir (opsiyonel)
7. Kapanış: canlı URL + GitHub
