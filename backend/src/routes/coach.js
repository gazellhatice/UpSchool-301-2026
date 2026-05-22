import { Router } from 'express';
import { generateCoachReply, getActiveProvider, mapLlmError } from '../services/llm.js';
import { verifyFirebaseToken } from '../middleware/auth.js';

export const coachRouter = Router();

coachRouter.post('/chat', verifyFirebaseToken, async (req, res) => {
  try {
    console.log('[coach/chat] istek alındı', new Date().toISOString());
    const { messages, financialContext } = req.body ?? {};

    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ error: 'messages dizisi gerekli' });
    }

    for (const msg of messages) {
      if (!msg?.text || !['user', 'assistant'].includes(msg.role)) {
        return res.status(400).json({ error: 'Geçersiz mesaj formatı' });
      }
      if (typeof msg.text !== 'string' || msg.text.length > 4000) {
        return res.status(400).json({ error: 'Mesaj metni geçersiz veya çok uzun' });
      }
    }

    const recent = messages.length > 20 ? messages.slice(-20) : messages;
    const reply = await generateCoachReply({
      messages: recent,
      financialContext,
    });

    console.log('[coach/chat] yanıt gönderildi', reply.slice(0, 80));

    res.json({
      reply,
      provider: getActiveProvider(),
      userId: req.user?.uid,
    });
  } catch (err) {
    console.error('Coach chat error:', err);
    res.status(500).json({
      error: mapLlmError(err),
      detail: process.env.NODE_ENV === 'development' ? err.message : undefined,
    });
  }
});

coachRouter.post('/analyze', verifyFirebaseToken, async (req, res) => {
  try {
    const { financialContext } = req.body ?? {};
    if (!financialContext) {
      return res.status(400).json({ error: 'financialContext gerekli' });
    }

    const prompt =
      'Bu ayki harcama verilerime dayanarak kısa bir finansal sağlık özeti ver. ' +
      'Güçlü yönler, dikkat edilmesi gereken alanlar ve 3 somut tasarruf önerisi sun.';

    const reply = await generateCoachReply({
      messages: [{ role: 'user', text: prompt }],
      financialContext,
    });

    res.json({ analysis: reply, provider: getActiveProvider(), userId: req.user?.uid });
  } catch (err) {
    console.error('Coach analyze error:', err);
    res.status(500).json({ error: mapLlmError(err) });
  }
});
