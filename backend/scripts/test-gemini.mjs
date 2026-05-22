import 'dotenv/config';
import { generateCoachReply, getActiveProvider } from '../src/services/llm.js';

console.log('AI sağlayıcı:', getActiveProvider() ?? 'YOK — key ekleyin');
console.log('Test isteği gönderiliyor...\n');

try {
  const reply = await generateCoachReply({
    messages: [{ role: 'user', text: 'Merhaba, tek cümleyle kendini tanıt.' }],
    financialContext: null,
  });
  console.log('✅ BAŞARILI!');
  console.log(reply);
} catch (err) {
  console.error('❌ HATA:', err.message?.split('\n')[0] ?? err);
  console.error(`
OpenRouter (önerilen — ücretsiz modeller):
1. https://openrouter.ai/keys → API key al
2. backend/.env:
   AI_PROVIDER=openrouter
   OPENROUTER_API_KEY=sk-or-...
   OPENROUTER_MODEL=google/gemma-2-9b-it:free
3. npm run dev

Gemini:
   AI_PROVIDER=gemini
   GEMINI_API_KEY=...
`);
  process.exit(1);
}
