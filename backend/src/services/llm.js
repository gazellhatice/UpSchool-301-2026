import { generateGeminiReply, isGeminiConfigured } from './providers/gemini.js';
import { generateOpenRouterReply, isOpenRouterConfigured } from './providers/openrouter.js';

export function getActiveProvider() {
  const configured = process.env.AI_PROVIDER?.trim().toLowerCase() || 'auto';

  if (configured === 'openrouter') return 'openrouter';
  if (configured === 'gemini') return 'gemini';

  // auto: OpenRouter öncelikli (ücretsiz modeller, kota sorunu daha az)
  if (isOpenRouterConfigured()) return 'openrouter';
  if (isGeminiConfigured()) return 'gemini';
  return null;
}

export function mapLlmError(err) {
  const msg = err?.message ?? String(err);
  if (msg.includes('429') || msg.includes('quota') || msg.includes('Too Many')) {
    return 'AI kotası doldu. AI_PROVIDER=openrouter ve OpenRouter key dene, veya 1-2 dk bekle.';
  }
  if (msg.includes('OPENROUTER_API_KEY')) {
    return 'OpenRouter API anahtarı yok. https://openrouter.ai/keys adresinden al.';
  }
  if (msg.includes('GEMINI_API_KEY')) {
    return 'Gemini API anahtarı yok. backend/.env dosyasını kontrol et.';
  }
  if (msg.includes('API key') || msg.includes('API_KEY')) {
    return 'API anahtarı geçersiz. backend/.env dosyasını kontrol et.';
  }
  return msg.split('\n')[0];
}

export async function generateCoachReply({ messages, financialContext }) {
  const provider = getActiveProvider();

  if (!provider) {
    throw new Error(
      'AI yapılandırılmamış. OPENROUTER_API_KEY veya GEMINI_API_KEY ekleyin.',
    );
  }

  console.log(`[llm] sağlayıcı: ${provider}`);

  if (provider === 'openrouter') {
    try {
      return await generateOpenRouterReply({ messages, financialContext });
    } catch (err) {
      // OpenRouter başarısız + Gemini varsa yedekle
      if (isGeminiConfigured() && process.env.AI_PROVIDER?.trim().toLowerCase() !== 'openrouter') {
        console.warn('[llm] OpenRouter başarısız, Gemini deneniyor...');
        return generateGeminiReply({ messages, financialContext });
      }
      throw err;
    }
  }

  try {
    return await generateGeminiReply({ messages, financialContext });
  } catch (err) {
    // Gemini kota doldu + OpenRouter varsa yedekle
    const msg = err?.message ?? '';
    if (
      isOpenRouterConfigured() &&
      (msg.includes('429') || msg.includes('quota') || msg.includes('Too Many'))
    ) {
      console.warn('[llm] Gemini kotası doldu, OpenRouter deneniyor...');
      return generateOpenRouterReply({ messages, financialContext });
    }
    throw err;
  }
}
