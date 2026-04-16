# 💰 Kişisel Harcama Koçu

> Banka ekstrenizi yükleyin, yapay zeka koçunuzla konuşun — yargılanmadan, rakamların arkasındaki alışkanlıkları keşfedin.

![Status](https://img.shields.io/badge/durum-geliştiriliyor-yellow)
![PRD](https://img.shields.io/badge/PRD-v1.0-green)
![Stack](https://img.shields.io/badge/YZ-...%20API-blueviolet)

---

## 🧠 Ne Soruyor Bu Uygulama?

> *"Bu ay yeme-içmeye geçen aya göre %40 daha fazla harcadın. Bir şeyler mi değişti?"*

Geleneksel bütçe uygulamaları sana pasta grafik gösterir. **Kişisel Harcama Koçu**, seninle konuşur.

PDF banka ekstrenizi yükleyin → YZ harcamalarınızı kategorize etsin → Kişisel koçunuzla sohbet edin → Alışkanlıklarınızı anlayın.

---

## ✨ Özellikler

| Özellik | Açıklama |
|---|---|
| 📄 **PDF Ekstre Analizi** | Ziraat, Garanti, İş Bankası, Yapı Kredi formatlarını okur |
| 🗂️ **Otomatik Kategorilendirme** | Market, Yeme-İçme, Ulaşım, Eğlence ve 4 kategori daha |
| 📊 **Anlık Dashboard** | Kategori dağılımı, en yüksek harcamalar, aylık karşılaştırma |
| 🤖 **YZ Koçluk Sohbeti** | Api destekli, empati kuran ve yargılamayan koç |
| 📬 **Haftalık Rapor** | Her Pazartesi gelen kişisel harcama özeti |

---

## 🖼️ Uygulama Akışı

```
Ekstre Yükle  →  YZ Analiz Eder  →  Dashboard  →  Koçla Sohbet
     📄               ⚙️               📊              💬
```

---

## 🛠️ Teknoloji Yığını

```
Frontend        →  Next.js 14 + Tailwind CSS
Backend         →  FastAPI (Python)
YZ / Koç        →  Anthropic ... API
PDF İşleme      →  pdfplumber + tabula-py
Veritabanı      →  PostgreSQL (Supabase)
Auth            →  Supabase Auth
E-posta         →  Resend API
Hosting         →  Vercel + Railway
```
---

## 📄 Belgeler

- 📋 [MVP Kapsamı →](./MVP_SCOPE.md) — Hangi özellikler yapılıyor, hangileri sonraya bırakıldı, 6 haftalık takvim
- 📐 [PRD →](./PRD.md) — Tüm ürün gereksinimleri, kullanıcı personaları, risk analizi, başarı metrikleri

---

## 🎯 Neden Bu Ürün?

Türkiye'de finansal okuryazarlık araçları iki uçta takılı:

- 🏦 **Banka uygulamaları** → Veriyi gösterir, yönlendirmez
- 👔 **Finansal danışmanlar** → Pahalı, büyük çoğunluğa ulaşmaz

Bu aradaki boşluğu doldurmak için: herkesin erişebileceği, gerçekten konuşan bir koç.

---

## 🗓️ Geliştirme Takvimi

- [x] Ürün fikri ve araştırma
- [x] MVP kapsamı tanımlandı
- [x] PRD yazıldı
- [ ] PDF parse motoru
- [ ] Dashboard UI
- [ ] API entegrasyonu
- [ ] Koçluk sohbet arayüzü
- [ ] Kapalı beta lansmanı

---

<p align="center">YZ Ürün Geliştirme Bootcamp — Nisan 2026</p>
