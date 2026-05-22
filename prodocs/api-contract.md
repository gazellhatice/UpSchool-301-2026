# API Contract — Backend

Base URL: `http://localhost:3001` (dev) | `https://YOUR-SERVICE.onrender.com` (prod)

## Authentication

Tüm `/api/v1/coach/*` endpoint'leri:

```
Authorization: Bearer <Firebase ID Token>
```

Development modunda token opsiyonel. Production'da zorunlu.

---

## GET /health

**Response 200:**
```json
{
  "status": "ok",
  "service": "kisisel-harcama-kocu-backend",
  "version": "1.0.0",
  "geminiConfigured": true,
  "timestamp": "2026-05-22T12:00:00.000Z"
}
```

---

## POST /api/v1/coach/chat

**Request:**
```json
{
  "messages": [
    { "role": "user", "text": "Bu ay çok mu harcadım?" },
    { "role": "assistant", "text": "..." }
  ],
  "financialContext": {
    "month": "Mayıs 2026",
    "income": 25000,
    "expense": 18500,
    "balance": 6500,
    "usagePercent": 74,
    "topCategories": [
      { "name": "Yemek", "amount": 4500, "percent": 24.3 }
    ],
    "recentTransactions": [
      { "date": "20 May", "amount": 150, "type": "expense", "category": "Yemek" }
    ]
  }
}
```

**Response 200:**
```json
{
  "reply": "Bu ay gelirinin %74'ünü harcamışsın...",
  "model": "gemini-2.0-flash",
  "userId": "firebase-uid"
}
```

**Errors:** 400 (validation), 401 (auth), 500 (Gemini/config)

---

## POST /api/v1/coach/analyze

**Request:**
```json
{
  "financialContext": { "...": "..." }
}
```

**Response 200:**
```json
{
  "analysis": "Bu ayki finansal sağlığın...",
  "userId": "firebase-uid"
}
```
