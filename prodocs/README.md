# Prodocs — Geliştirme Referans Dosyaları

Bu klasör, projenin ürün tanımı, teknik planı, tasarım kuralları ve geliştirme günlüğünü içerir. AI ajanları ve geliştiriciler için referans niteliğindedir.

## Zorunlu dokümanlar

| Dosya | Açıklama |
|-------|----------|
| [PRD.md](PRD.md) | Problem, hedef kitle, kullanıcı hikâyeleri, gereksinimler |
| [tech-stack.md](tech-stack.md) | Teknoloji seçimleri, mimari, AI kullanımı |
| [Plan.md](Plan.md) | PRD'den türetilmiş teknik adımlar |
| [DesignSystem.md](DesignSystem.md) | Renk, tipografi, bileşen kuralları |
| [Progress.md](Progress.md) | Yapılan işler, kararlar, hatalar (Nisan 2026'dan itibaren) |

## Ek referanslar

| Dosya | Açıklama |
|-------|----------|
| [architecture.md](architecture.md) | Sistem mimarisi ve veri akışı |
| [api-contract.md](api-contract.md) | Backend API sözleşmesi |
| [conventions.md](conventions.md) | Kod yazım kuralları |
| [mvp-scope.md](mvp-scope.md) | MVP kapsamı ve kabul kriterleri |

## Hızlı bağlam

- **Frontend:** `../frontend/` — Flutter (Dart)
- **Backend:** `../backend/` — Node.js Express
- **Ana AI özellik:** Finans Koçu (Gemini LLM, backend API)
- **Veri:** Drift (yerel) + Firestore (bulut)

## Ajan / geliştirici kuralları

1. API anahtarlarını frontend'e veya repoya yazma
2. Yeni özellikler `frontend/lib/features/` altında feature-first yapıda olsun
3. LLM çağrıları yalnızca `backend/src/` üzerinden
4. Türkçe UI metinleri kullan
5. Mevcut tema (`AppColors`, `GlassCard`, `AppLogo`) ile tutarlı kal
