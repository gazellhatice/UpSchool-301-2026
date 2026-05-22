export const SYSTEM_PROMPT = `Sen "Finans Koçu" adlı kişisel bir finans asistanısın.
Kullanıcıların kişisel harcamalarını yönetmelerine, bütçe planlamalarına ve finansal hedeflerine ulaşmalarına yardımcı olursun.

Kurallar:
- Yanıtların kısa, net ve pratik olsun (maksimum 3-4 paragraf).
- Her zaman Türkçe konuş.
- Dostça ve motive edici bir ton kullan.
- Kullanıcının gerçek finans verisi varsa bunu referans al; uydurma rakam verme.
- Somut, uygulanabilir adımlar öner.
- Yatırım tavsiyesi verme; genel finansal okuryazarlık ve bütçe odaklı kal.
- Tıbbi veya hukuki tavsiye verme.`;

export function buildContextBlock(financialContext) {
  if (!financialContext) return '';

  const lines = ['\n\n--- Kullanıcının güncel finans özeti ---'];
  if (financialContext.month) lines.push(`Dönem: ${financialContext.month}`);
  if (financialContext.income != null) {
    lines.push(`Toplam gelir: ₺${formatMoney(financialContext.income)}`);
  }
  if (financialContext.expense != null) {
    lines.push(`Toplam gider: ₺${formatMoney(financialContext.expense)}`);
  }
  if (financialContext.balance != null) {
    lines.push(`Net bakiye: ₺${formatMoney(financialContext.balance)}`);
  }
  if (financialContext.usagePercent != null) {
    lines.push(`Gelire göre harcama oranı: %${financialContext.usagePercent.toFixed(1)}`);
  }
  if (financialContext.topCategories?.length) {
    lines.push('En çok harcanan kategoriler:');
    for (const cat of financialContext.topCategories.slice(0, 5)) {
      lines.push(
        `  • ${cat.name}: ₺${formatMoney(cat.amount)} (%${cat.percent?.toFixed?.(1) ?? cat.percent})`,
      );
    }
  }
  if (financialContext.recentTransactions?.length) {
    lines.push('Son işlemler:');
    for (const tx of financialContext.recentTransactions.slice(0, 5)) {
      const sign = tx.type === 'income' ? '+' : '-';
      lines.push(
        `  • ${tx.date}: ${sign}₺${formatMoney(tx.amount)} — ${tx.category}${tx.note ? ` (${tx.note})` : ''}`,
      );
    }
  }
  lines.push('---\n');
  return lines.join('\n');
}

function formatMoney(n) {
  return Number(n).toLocaleString('tr-TR', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
}

export function buildSystemMessage(financialContext) {
  return SYSTEM_PROMPT + buildContextBlock(financialContext);
}
