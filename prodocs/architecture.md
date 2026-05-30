# Mimari

## Katmanlar

```
Presentation (Flutter widgets)
    ↓ Riverpod providers
Domain (models: TransactionItem, CategoryItem)
    ↓
Data (FinanceRepository, Drift, Firestore mappers)
    ↓
External (Firebase Auth, Firestore, Backend API, Gemini)
```

## Platform stratejisi

**Tek Flutter `frontend/`** — iş mantığı ve ekranlar paylaşılır; yalnızca **kabuk (shell)** platforma göre değişir.

| Platform | UI kabuğu | Navigasyon | Yerel veri | Bulut |
|----------|-----------|------------|------------|-------|
| **Android / iOS** | `HomeShellMobile` | Alt 4 sekme + FAB | Drift **SQLite** | Firestore |
| **Web (≥900px)** | `HomeShellWeb` | Sol sidebar + üst çubuk | Drift **WASM** | Firestore |
| **Web (<900px)** | `HomeShellMobile` | Alt 4 sekme + FAB (mobil ile aynı) | Drift WASM | Firestore |

Giriş: Firebase Auth (e-posta + Google). **Mobilde** native Google Sign-In; **web'de** `signInWithPopup`. Aynı `uid` → aynı Firestore verisi → mobilde eklenen işlem web'de görünür.

## AI Koç Veri Akışı

```
1. Kullanıcı mesaj yazar (CoachChatScreen)
2. Frontend yerel Drift'ten ay özeti + kategori istatistiklerini okur
3. financial_context_builder → JSON bağlam oluşturur
4. CoachApiService → POST /api/v1/coach/chat (Firebase ID token ile)
5. Backend auth middleware token doğrular
6. gemini.js → system prompt + finans bağlamı + mesaj geçmişi → Gemini API
7. Yanıt frontend'e döner, Firestore coach_chat'e kaydedilir
```

## Firestore Şeması

```
users/{userId}
  ├── (profil alanları)
  ├── categories/{categoryId}
  ├── transactions/{transactionId}
  └── coach_chat/{messageId}
        ├── role: "user" | "assistant"
        ├── text: string
        └── createdAt: timestamp
```

## Offline Stratejisi

- İşlemler önce Drift'e yazılır (`synced: false`)
- Online olunca FinanceRepository push yapar
- Girişte `initialize()` → Firestore'dan pull (web'de sayfa yenilense bile veri geri gelir)
- AI koç internet gerektirir (backend API)

## Web routing (go_router)

| URL | Ekran | Auth |
|-----|-------|------|
| `/` | Landing | Hayır |
| `/hakkimizda` | Hakkında | Hayır |
| `/iletisim` | İletişim | Hayır |
| `/gizlilik` | Gizlilik | Hayır |
| `/indir` | Mobil indirme (QR) | Hayır |
| `/giris` | Giriş / kayıt | Hayır |
| `/uygulama/ozet` | Özet | Evet |
| `/uygulama/analiz` | Analiz | Evet |
| `/uygulama/takvim` | Takvim | Evet |
| `/uygulama/profil` | Profil | Evet |

`AppNavigationSync` web'de sekme indeksi ile URL'i iki yönlü senkron tutar.

## Web dosyaları

```
frontend/web/
├── sqlite3.wasm       # SQLite WebAssembly modülü
├── drift_worker.js    # Drift arka plan worker
├── index.html         # SEO meta
└── manifest.json      # PWA

backend/
└── render.yaml        # Render deploy şablonu (kökte değil)
```

`run_chrome.ps1` WASM dosyaları yoksa GitHub release'lerinden indirir.
