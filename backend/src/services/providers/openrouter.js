import { buildSystemMessage } from '../prompt.js';

const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions';

const DEFAULT_MODELS = [
  'openrouter/free',
  'google/gemma-4-26b-a4b-it:free',
  'google/gemma-3-4b-it:free',
  'meta-llama/llama-3.2-3b-instruct:free',
];

export async function generateOpenRouterReply({ messages, financialContext }) {
  const apiKey = process.env.OPENROUTER_API_KEY?.trim();
  if (!apiKey) throw new Error('OPENROUTER_API_KEY yapılandırılmamış');

  const preferred = process.env.OPENROUTER_MODEL?.trim();
  const models = [...new Set([preferred, ...DEFAULT_MODELS].filter(Boolean))];

  const chatMessages = [
    { role: 'system', content: buildSystemMessage(financialContext) },
    ...messages.map((m) => ({
      role: m.role === 'assistant' ? 'assistant' : 'user',
      content: m.text,
    })),
  ];

  let lastError;
  for (const model of models) {
    try {
      console.log(`[openrouter] model: ${model}`);
      const response = await fetch(OPENROUTER_URL, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': process.env.OPENROUTER_SITE_URL || 'http://localhost:3001',
          'X-Title': 'Kisisel Harcama Kocu',
        },
        body: JSON.stringify({
          model,
          messages: chatMessages,
          max_tokens: 1024,
          temperature: 0.7,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        const errMsg = data?.error?.message ?? response.statusText;
        throw new Error(`OpenRouter ${response.status}: ${errMsg}`);
      }

      const reply = data?.choices?.[0]?.message?.content?.trim();
      if (!reply) throw new Error('OpenRouter boş yanıt döndü');
      return reply;
    } catch (err) {
      lastError = err;
      const msg = err?.message ?? '';
      if (msg.includes('429') || msg.includes('rate') || msg.includes('quota')) {
        console.warn(`[openrouter] limit (${model}), sonraki...`);
        continue;
      }
      if (models.indexOf(model) < models.length - 1) {
        console.warn(`[openrouter] hata (${model}): ${msg.split('\n')[0]}`);
        continue;
      }
      throw err;
    }
  }

  throw lastError ?? new Error('OpenRouter yanıt vermedi');
}

export function isOpenRouterConfigured() {
  return Boolean(process.env.OPENROUTER_API_KEY?.trim());
}
