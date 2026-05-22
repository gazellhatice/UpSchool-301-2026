# Kod Kuralları

## Flutter (frontend/)

- Feature-first: `lib/features/<feature>/presentation|data`
- Paylaşılan kod: `lib/core/`
- State: Riverpod (`ConsumerWidget`, `StreamProvider`)
- Para formatı: `formatCurrency()` — `currency_format.dart`
- Onay diyalogları: `showConfirmDialog()`
- Tema: `AppColors`, `context.palette`, `GlassCard`

## Backend (backend/)

- ES modules (`import/export`)
- Route'lar: `src/routes/`
- İş mantığı: `src/services/`
- Env: `process.env` via dotenv
- Hata yanıtları: `{ error: "mesaj" }`

## Commit Mesajları

- Türkçe veya İngilizce, emir kipi
- Örnek: `feat: backend coach API eklendi`

## Güvenlik

- `.env` commit etme
- API key frontend'de tutma
- Firestore rules: kullanıcı yalnızca kendi verisine erişir
