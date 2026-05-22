import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { coachRouter } from './routes/coach.js';
import { getActiveProvider } from './services/llm.js';
const app = express();
const port = Number(process.env.PORT) || 3001;

const allowedOrigins = (process.env.CORS_ORIGINS || 'http://localhost:8080')
  .split(',')
  .map((o) => o.trim())
  .filter(Boolean);

const isDev = process.env.NODE_ENV !== 'production';

app.use(
  cors({
    origin(origin, callback) {
      if (
        !origin ||
        allowedOrigins.includes('*') ||
        allowedOrigins.includes(origin) ||
        (isDev && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin))
      ) {
        callback(null, true);
      } else {
        callback(new Error(`CORS: ${origin} izinli değil`));
      }
    },
    credentials: true,
  }),
);

app.use(express.json({ limit: '256kb' }));

app.get('/', (_req, res) => {
  res.json({
    message: 'Kişisel Harcama Koçu Backend çalışıyor',
    health: '/health',
    api: '/api/v1',
    coachChat: 'POST /api/v1/coach/chat',
  });
});

app.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    service: 'kisisel-harcama-kocu-backend',
    version: '1.0.0',
    aiProvider: getActiveProvider(),
    openRouterConfigured: Boolean(process.env.OPENROUTER_API_KEY),
    geminiConfigured: Boolean(process.env.GEMINI_API_KEY),
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/v1', (_req, res) => {
  res.json({
    name: 'Kişisel Harcama Koçu API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /health',
      coachChat: 'POST /api/v1/coach/chat',
      coachAnalyze: 'POST /api/v1/coach/analyze',
    },
  });
});

app.use('/api/v1/coach', coachRouter);

app.use((_req, res) => {
  res.status(404).json({ error: 'Endpoint bulunamadı' });
});

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: err.message || 'Sunucu hatası' });
});

app.listen(port, () => {
  console.log(`Backend http://localhost:${port}`);
  console.log(`AI sağlayıcı: ${getActiveProvider() ?? 'YOK'}`);
  console.log(`CORS origins: ${allowedOrigins.join(', ')}`);
});