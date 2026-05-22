# Prodocs — AI Ajan Referans Dosyaları

Bu klasör, Cursor veya benzeri AI ajanlarının projeyi hızlıca anlaması için referans materyaller içerir.

## Dosyalar

| Dosya | Açıklama |
|-------|----------|
| [architecture.md](architecture.md) | Sistem mimarisi ve veri akışı |
| [api-contract.md](api-contract.md) | Backend API sözleşmesi |
| [conventions.md](conventions.md) | Kod yazım kuralları |

## Hızlı Bağlam

- **Proje:** Kişisel Harcama Koçu — yapay zeka destekli finans takip uygulaması
- **Frontend:** `../frontend/` — Flutter (Dart)
- **Backend:** `../backend/` — Node.js Express
- **Ana AI özellik:** Finans Koçu (Gemini LLM, backend üzerinden)
- **Veri:** Drift (local) + Firestore (cloud sync)

## Ajan Talimatları

1. API anahtarlarını asla frontend'e veya repoya yazma
2. Yeni özellikler `frontend/lib/features/` altında feature-first yapıda olsun
3. LLM çağrıları yalnızca `backend/src/` üzerinden
4. Türkçe UI metinleri kullan
5. Mevcut tema (`AppColors`, `GlassCard`) ile tutarlı kal
