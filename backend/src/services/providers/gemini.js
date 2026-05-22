import { GoogleGenerativeAI } from '@google/generative-ai';
import { buildSystemMessage } from '../prompt.js';

const FALLBACK_MODELS = ['gemini-1.5-flash', 'gemini-2.0-flash-lite', 'gemini-2.0-flash'];

function isQuotaError(err) {
  const msg = err?.message ?? '';
  return msg.includes('429') || msg.includes('quota') || msg.includes('Too Many');
}

async function callModel({ genAI, modelName, messages, financialContext }) {
  const model = genAI.getGenerativeModel({
    model: modelName,
    systemInstruction: buildSystemMessage(financialContext),
  });

  const history = messages.slice(0, -1).map((m) => ({
    role: m.role === 'assistant' ? 'model' : 'user',
    parts: [{ text: m.text }],
  }));

  const lastMessage = messages[messages.length - 1];
  if (!lastMessage || lastMessage.role !== 'user') {
    throw new Error('Son mesaj kullanıcıdan olmalı');
  }

  const chat = model.startChat({
    history,
    generationConfig: { maxOutputTokens: 1024, temperature: 0.7 },
  });

  const result = await chat.sendMessage(lastMessage.text);
  const reply = result.response.text()?.trim();
  if (!reply) throw new Error('Model boş yanıt döndü');
  return reply;
}

export async function generateGeminiReply({ messages, financialContext }) {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) throw new Error('GEMINI_API_KEY yapılandırılmamış');

  const preferred = process.env.GEMINI_MODEL?.trim() || 'gemini-1.5-flash';
  const models = [...new Set([preferred, ...FALLBACK_MODELS])];
  const genAI = new GoogleGenerativeAI(apiKey);

  let lastError;
  for (const modelName of models) {
    try {
      console.log(`[gemini] model: ${modelName}`);
      return await callModel({ genAI, modelName, messages, financialContext });
    } catch (err) {
      lastError = err;
      if (isQuotaError(err)) {
        console.warn(`[gemini] kota (${modelName}), sonraki...`);
        continue;
      }
      throw err;
    }
  }
  throw lastError ?? new Error('Gemini yanıt vermedi');
}

export function isGeminiConfigured() {
  return Boolean(process.env.GEMINI_API_KEY?.trim());
}
