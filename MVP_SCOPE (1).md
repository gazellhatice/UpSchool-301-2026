# Kişisel Harcama Koçu — MVP Kapsamı

## 🎯 Ürün Özeti

**Kişisel Harcama Koçu**, kullanıcıların PDF banka ekstrelerini yükleyerek yapay zeka destekli kişisel bir finans koçuyla konuşmasını sağlayan bir web uygulamasıdır. Geleneksel PFM (kişisel finans yönetimi) araçlarının aksine, rakamları sadece göstermez; kullanıcıyla empati kurarak alışkanlık değişikliği önerir ve motivasyon sağlar.

---

## 👤 Hedef Kullanıcı (MVP)

- 22–35 yaş arası, aylık düzenli geliri olan çalışanlar
- Harcamalarının nereye gittiğini merak eden ama spreadsheet açmaya üşünen kişiler
- Finansal koçluğa ilgi duyan ama bütçesi olmayan bireyler

---

## ✅ MVP Kapsamındaki Özellikler

### 1. PDF Ekstre Yükleme
- Kullanıcı, banka/kredi kartı ekstresini PDF olarak yükler
- Desteklenen bankalar (MVP): Ziraat, Garanti, İş Bankası, Yapı Kredi formatları
- Dosya boyutu limiti: 10 MB

### 2. Otomatik Harcama Kategorilendirme
- YZ, PDF'ten işlemleri çıkarır ve kategorilere ayırır
- Kategoriler: Market, Yeme-İçme, Ulaşım, Eğlence, Fatura, Alışveriş, Sağlık, Diğer
- Kullanıcı yanlış kategoriyi düzeltebilir (feedback loop)

### 3. Özet Dashboard
- Aylık toplam harcama
- Kategori bazlı pasta grafiği
- En yüksek 3 harcama kalemi
- Geçen aya göre değişim (2. ekstre yüklendikten sonra)

### 4. Konuşma Tabanlı Koçluk Arayüzü
- Kullanıcı, YZ koçuyla chat arayüzü üzerinden konuşur
- Koç, kullanıcıyı tanımlayan ve yargılamayan bir dil kullanır
- Örnek koç mesajları:
  - _"Bu ay yeme-içmeye geçen aya göre %40 daha fazla harcadın. Bir şeyler mi değişti?"_
  - _"Market harcamaların gayet makul görünüyor, devam et!"_
  - _"Streaming aboneliklerine toplam ₺850 gidiyor. Bunların hepsini aktif kullanıyor musun?"_

### 5. Haftalık Özet Raporu (E-posta)
- Kullanıcı e-posta adresi girerse haftalık harcama özeti gönderilir
- Basit HTML e-posta: kategori dağılımı + koçtan 1 ipucu

---

## 🚫 MVP Kapsamı Dışında (Sonraki Sürümler)

| Özellik | Neden Dışarıda? |
|---|---|
| Banka API entegrasyonu (open banking) | Regülasyon karmaşıklığı |
| Bütçe hedefi belirleme | Koçluk akışını karmaşıklaştırır |
| Çoklu kullanıcı (aile/çift modu) | Veri izolasyonu zorlukları |
| Yatırım takibi | Farklı bir kullanıcı kitlesi |
| Mobil uygulama (iOS/Android) | PWA yeterli, native sonraya |
| Türkçe NLP fine-tuning | Genel LLM yeterli MVP için |

---

## 🛠️ Teknik Yığın (MVP)

| Katman | Teknoloji |
|---|---|
| Frontend | Next.js 14 + Tailwind CSS |
| Backend | FastAPI (Python) |
| YZ / LLM | Projeye uygunluğuna göre karar verilecektir |
| PDF Parsing | pdfplumber + tabula-py |
| Veritabanı | PostgreSQL (Supabase) |
| Kimlik Doğrulama | Supabase Auth (e-posta + Google) |
| Hosting | Vercel (frontend) + Railway (backend) |
| E-posta | Resend API |

---

## 📐 Kullanıcı Akışı (Happy Path)

```
1. Kullanıcı kaydolur (e-posta veya Google)
      ↓
2. PDF banka ekstresini yükler
      ↓
3. YZ işlemleri parse eder (~10-30 sn)
      ↓
4. Dashboard açılır: kategoriler + özet
      ↓
5. Koç, otomatik bir gözlemle sohbeti başlatır
      ↓
6. Kullanıcı koçla sohbet eder
      ↓
7. (Opsiyonel) Haftalık e-posta için abone olur
```

---


## 🗓️ MVP Geliştirme Takvimi (6 Hafta)

| Hafta | Görev |
|---|---|
| 1 | PDF parsing + kategori çıkarma motoru |
| 2 | Dashboard UI + kategori düzenleme |
| 3 | API entegrasyonu + koçluk prompt tasarımı |
| 4 | Konuşma arayüzü + context yönetimi |
| 5 | Kimlik doğrulama + veri saklama + e-posta |
| 6 | Test, hata düzeltme, ilk kullanıcı lansmanı |

---

