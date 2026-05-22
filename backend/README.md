# Backend — Kişisel Harcama Koçu API

Node.js Express REST API. Gemini LLM proxy; Finans Koçu sohbet ve analiz.

## Kurulum

```bash
cp .env.example .env
npm install
npm run dev
```

## Endpoints

- `GET /health`
- `POST /api/v1/coach/chat`
- `POST /api/v1/coach/analyze`

Detaylı sözleşme: [../prodocs/api-contract.md](../prodocs/api-contract.md)

## Deploy (Render)

1. Render'da New Web Service
2. Root Directory: `backend`
3. Env: `GEMINI_API_KEY`, `CORS_ORIGINS`, `FIREBASE_PROJECT_ID`, `FIREBASE_SERVICE_ACCOUNT`
