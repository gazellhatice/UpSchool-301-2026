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
- AI koç internet gerektirir (backend API)
