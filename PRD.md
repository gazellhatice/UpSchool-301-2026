# Product Requirements Document (PRD)
## Kişisel Harcama Koçu

**Versiyon:** 1.0  
**Tarih:** Nisan 2026  
**Ürün Sahibi:** Hatice Gazel  
**Durum:** Draft

---

## 1. Giriş ve Motivasyon

### 1.1 Problem Tanımı

Türkiye'de çalışan nüfusun büyük çoğunluğu, aylık harcamalarının nereye gittiğini net olarak bilmemektedir. Mevcut çözümler iki uç noktada kalmaktadır:

- **Pasif araçlar** (banka uygulamaları): Harcamaları gösterir fakat kullanıcıyı yönlendirmez.
- **Aktif danışmanlık** (finansal koç, danışman): Erişimi pahalı, büyük çoğunluğa ulaşmaz.

Bu iki uç arasındaki boşluk, empati kurarak konuşan ve kişiselleştirilmiş gözlem yapabilen yapay zeka destekli bir koç ile doldurulabilir.

### 1.2 Çözüm

**Kişisel Harcama Koçu**, kullanıcının banka ekstresini yüklemesiyle başlayan, yapay zeka destekli konuşma tabanlı bir finansal koçluk uygulamasıdır. Uygulama, kullanıcıyı yargılamadan, kişisel bağlamı anlayarak alışkanlık değişikliği için zemin hazırlar.

### 1.3 Vizyon

> "Herkesin cebinde, ona özel konuşan bir finansal koç."

---

## 2. Hedefler ve Başarı Kriterleri

### 2.1 İş Hedefleri

- 3 ay içinde 1.000 aktif kullanıcıya ulaşmak
- Aylık %15 organik büyüme (referans + içerik)
- 6. ayda freemium → premium dönüşüm oranını %8'e çıkarmak

### 2.2 Kullanıcı Hedefleri

- Kullanıcı, "Bu ay neye çok harcadım?" sorusuna 2 dakikada cevap bulabilmeli
- Kullanıcı, koçla yaptığı ilk sohbetten sonra en az 1 somut aksiyon adımı belirleyebilmeli
- Kullanıcı, uygulamayı başkasına önermek isteyecek kadar değer bulmalı (NPS ≥ 35)

### 2.3 Temel Metrikler (KPI)

| Metrik | MVP Hedefi | 6 Ay Hedefi |
|---|---|---|
| Kayıtlı kullanıcı | 500 | 5.000 |
| Aylık aktif kullanıcı (MAU) | 300 | 2.500 |
| Ekstre yükleme başarı oranı | %85 | %92 |
| Koç ile ortalama mesaj/oturum | 4 | 7 |
| Haftalık e-posta açılma oranı | %35 | %45 |
| Premium dönüşüm oranı | — | %8 |

---

## 3. Kullanıcı Personaları

### Persona 1 — "Meraklı Mert"
- **Yaş/Durum:** 27, yazılım geliştirici, İstanbul
- **Motivasyon:** Maaşı iyi ama ay sonuna para kalmıyor, nedenini anlamak istiyor
- **Korkusu:** Yatırım yapmayı erteliyor, nereden başlayacağını bilmiyor
- **Kullanım şekli:** Akşam telefonda, ayda 1–2 kez ekstre yükler, koçla kısa sohbet eder

### Persona 2 — "Tasarruf Odaklı Tuğçe"
- **Yaş/Durum:** 33, öğretmen, Ankara
- **Motivasyon:** Ev almak için birikim yapıyor, harcamalarını kısmak istiyor
- **Korkusu:** Rakamları görmekten kaçınıyor, "çok harcıyorum" duygusuyla utanıyor
- **Kullanım şekli:** Koçun yargılamayan tonunu seviyor, haftalık raporu düzenli takip eder

---

## 4. Özellik Gereksinimleri

### 4.1 Kullanıcı Yönetimi

#### 4.1.1 Kayıt ve Giriş

| ID | Gereksinim | Öncelik |
|---|---|---|
| AUTH-01 | Kullanıcı e-posta + şifreyle kayıt olabilmeli | P0 |
| AUTH-02 | Google OAuth ile giriş yapılabilmeli | P0 |
| AUTH-03 | Şifre sıfırlama e-posta akışı olmalı | P1 |
| AUTH-04 | Oturum 30 gün açık kalabilmeli (remember me) | P2 |

#### 4.1.2 Profil

| ID | Gereksinim | Öncelik |
|---|---|---|
| PROF-01 | Kullanıcı adı ve e-posta düzenlenebilmeli | P1 |
| PROF-02 | Kullanıcı para birimi tercihini seçebilmeli (₺ varsayılan) | P2 |
| PROF-03 | Hesap silinebilmeli ve tüm veriler temizlenmeli | P0 |

---

### 4.2 PDF Yükleme ve Parse Etme

#### 4.2.1 Dosya Yükleme

| ID | Gereksinim | Öncelik |
|---|---|---|
| UPLOAD-01 | Kullanıcı tek bir PDF dosyası yükleyebilmeli | P0 |
| UPLOAD-02 | Maksimum dosya boyutu 10 MB olmalı | P0 |
| UPLOAD-03 | Yükleme ilerleme göstergesi sunulmalı | P1 |
| UPLOAD-04 | Hatalı format veya bozuk dosya için açık hata mesajı olmalı | P0 |
| UPLOAD-05 | Yüklenen dosyalar şifreli depolanmalı (AES-256) | P0 |
| UPLOAD-06 | PDF'ler 90 gün sonra otomatik silinmeli | P1 |

#### 4.2.2 İşlem Çıkarma

| ID | Gereksinim | Öncelik |
|---|---|---|
| PARSE-01 | İşlem tarihi, tutarı ve açıklaması çıkarılabilmeli | P0 |
| PARSE-02 | Desteklenen bankalar: Ziraat, Garanti, İş Bankası, Yapı Kredi | P0 |
| PARSE-03 | Parse başarısız olursa kullanıcıya açık hata + destek yönlendirmesi yapılmalı | P0 |
| PARSE-04 | Parse süresi 30 saniyeyi geçmemeli | P1 |
| PARSE-05 | Kullanıcı hatalı kategorileri düzeltebilmeli | P1 |

#### 4.2.3 Kategorizasyon

| ID | Gereksinim | Öncelik |
|---|---|---|
| CAT-01 | İşlemler 8 ana kategoriye otomatik atanmalı | P0 |
| CAT-02 | Kategoriler: Market, Yeme-İçme, Ulaşım, Eğlence, Fatura, Alışveriş, Sağlık, Diğer | P0 |
| CAT-03 | Aynı isimli işyerinin sonraki atamaları hatırlanmalı | P2 |

---

### 4.3 Dashboard

| ID | Gereksinim | Öncelik |
|---|---|---|
| DASH-01 | Aylık toplam harcama belirgin şekilde gösterilmeli | P0 |
| DASH-02 | Kategori dağılımı pasta veya çubuk grafikle sunulmalı | P0 |
| DASH-03 | En yüksek 3 harcama kalemi listelenmeli | P0 |
| DASH-04 | İkinci ekstre yüklendikten sonra önceki ayla karşılaştırma gösterilmeli | P1 |
| DASH-05 | Dashboard mobil uyumlu olmalı (responsive) | P0 |
| DASH-06 | Kullanıcı grafiklere dokunup/tıklayıp detay görebilmeli | P1 |

---

### 4.4 Koçluk Konuşma Arayüzü

#### 4.4.1 Temel Chat

| ID | Gereksinim | Öncelik |
|---|---|---|
| CHAT-01 | Ekstre yüklendikten sonra koç otomatik bir gözlemle konuşmayı başlatmalı | P0 |
| CHAT-02 | Kullanıcı metin mesajı gönderebilmeli | P0 |
| CHAT-03 | Koç, kullanıcının harcama verisini bağlamında tutarak yanıt vermeli | P0 |
| CHAT-04 | Koç, empati kurmalı ve yargılayıcı dil kullanmamalı | P0 |
| CHAT-05 | Koç yanıtları akıcı şekilde (streaming) görünmeli | P1 |
| CHAT-06 | Konuşma geçmişi oturum boyunca korunmalı | P0 |
| CHAT-07 | Geçmiş konuşmalar liste halinde görüntülenebilmeli | P2 |

#### 4.4.2 Koçluk Kalitesi

| ID | Gereksinim | Öncelik |
|---|---|---|
| QUAL-01 | Koç, belirli kategorilerdeki anormal artışları proaktif olarak belirtmeli | P0 |
| QUAL-02 | Koç, somut ve uygulanabilir öneriler sunmalı | P0 |
| QUAL-03 | Koç, finans dışı konularda kapsam dışı olduğunu belirtmeli | P1 |
| QUAL-04 | Kullanıcı koç yanıtını beğenip/beğenmeyebilmeli (thumbs up/down) | P2 |

---

### 4.5 Haftalık E-posta Raporu

| ID | Gereksinim | Öncelik |
|---|---|---|
| EMAIL-01 | Kullanıcı haftalık rapora abone olabilmeli | P1 |
| EMAIL-02 | E-posta: kategori özeti + koçtan 1 ipucu içermeli | P1 |
| EMAIL-03 | E-postada abonelikten çıkma linki bulunmalı | P0 |
| EMAIL-04 | E-posta gönderimi her Pazartesi sabahı 08:00'de yapılmalı | P2 |

---

## 5. Teknik Gereksinimler

### 5.1 Performans

| Gereksinim | Hedef |
|---|---|
| PDF parse süresi | < 30 saniye |
| Sayfa yüklenme süresi (LCP) | < 2 saniye |
| Koç yanıt süresi (ilk token) | < 3 saniye |
| Servis uptime | %99.5 |

### 5.2 Güvenlik ve Gizlilik

| ID | Gereksinim |
|---|---|
| SEC-01 | Tüm veriler HTTPS üzerinden iletilmeli |
| SEC-02 | PDF'ler S3'te AES-256 ile şifreli saklanmalı |
| SEC-03 | İşlem verileri kullanıcı bazlı izole edilmeli |
| SEC-04 | LLM'e gönderilen verilerde kullanıcı adı ve IBAN maskelenmeli |
| SEC-05 | KVKK uyumlu aydınlatma metni ve onay akışı olmalı |
| SEC-06 | Oturum token'ları JWT + refresh token mimarisine dayanmalı |

### 5.3 Ölçeklenebilirlik

- MVP: Eş zamanlı 100 kullanıcı
- 6. ay: Eş zamanlı 1.000 kullanıcı (yatay ölçekleme ile)
- PDF parse servisi ayrı bir mikroservis olarak konuşlandırılmalı

---

## 6. Kullanıcı Deneyimi Gereksinimleri

### 6.1 Onboarding

1. Kayıt → E-posta doğrulama (opsiyonel, zorunlu değil MVP'de)
2. İlk giriş → "Nasıl çalışır" 3 adımlı tour
3. PDF yükleme yönlendirmesi → koç karşılama mesajı

### 6.2 Erişilebilirlik

- WCAG 2.1 AA standardına uyum hedeflenir
- Minimum kontrast oranı 4.5:1
- Tüm etkileşimli elementler klavye ile erişilebilir olmalı

### 6.3 Dil

- MVP dili: Türkçe
- Koç, resmi ama samimi bir dil kullanmalı
- Finansal jargondan kaçınılmalı; zorunlu kullanımlarda açıklama eklenmeli

---

## 7. Kısıtlar ve Varsayımlar

### Kısıtlar

- Banka API entegrasyonu (open banking) MVP kapsamı dışındadır
- Yalnızca PDF formatı desteklenmektedir; Excel veya CSV yükleme MVP'de yoktur
- Yatırım hesabı / borsa verisi desteklenmemektedir

### Varsayımlar

- Kullanıcıların büyük çoğunluğu Türkiye'deki bankalardan ekstre almaktadır
- Türkçe LLM çıktısı, genel amaçlı modelle (Claude) yeterli kalitede sağlanabilir
- Kullanıcılar finans verilerini yüklemeyi güvenli buluyor (onboarding'de güven mesajı ile desteklenir)

---

## 8. Riskler ve Azaltma Stratejileri

| Risk | Olasılık | Etki | Azaltma |
|---|---|---|---|
| PDF formatları çok farklı, parse başarısız | Yüksek | Yüksek | Banka özelinde şablonlar + kullanıcı manuel düzeltme |
| Kullanıcılar finansal veriyi yüklemek istemez | Orta | Yüksek | Güven iletişimi, KVKK uyumu, örnek veriyle demo modu |
| LLM koçluk yanıtları yüzeysel kalır | Orta | Orta | Prompt mühendisliği + kullanıcı geri bildirim döngüsü |
| Banka lisans gereklilikleri | Düşük | Yüksek | Fintech hukuk danışmanlığı, "koç" konumlandırması (tavsiye değil) |
| Kötüye kullanım (başkasının ekstresini yükleme) | Düşük | Orta | Kullanıcı onay akışı + ToS |

---

## 9. Yayın Planı

### Aşama 1 — Kapalı Beta (MVP, 6. Hafta Sonu)
- 50 davetli kullanıcıyla test
- Odak: PDF parse başarısı + koç kalitesi

### Aşama 2 — Açık Beta (8. Hafta)
- Waitlist ile genel erişim
- Kullanıcı geri bildirimine göre koçluk prompt'ları rafine edilir

### Aşama 3 — Genel Lansman (12. Hafta)
- Freemium model aktif
- Premium özellikler: çoklu ekstre karşılaştırma, bütçe hedefleri, gelişmiş raporlar

---

## 10. Açık Sorular

| # | Soru | Sorumlu | Hedef Tarih |
|---|---|---|---|
| 1 | Hangi bankalar MVP'de önceliklendirilecek? | Ürün + Mühendislik | Hafta 1 |
| 2 | Demo modu (sahte veri) sunulacak mı? | Ürün | Hafta 2 |
| 3 | Premium plan fiyatlandırması ne olacak? | Ürün + İş Geliştirme | Hafta 6 |
| 4 | "Koç" için bir isim/karakter yaratılacak mı? | Ürün + Tasarım | Hafta 3 |
| 5 | Kullanıcı verisi 3. taraf analitiğe gönderilecek mi? | Hukuk + Ürün | Hafta 2 |

---

## Ekler

### Ek A — Desteklenen Kategori Listesi

| Kategori | Örnek İşyerleri |
|---|---|
| Market | BİM, A101, Migros, CarrefourSA, Şok |
| Yeme-İçme | Getir, Yemeksepeti, kafeler, restoranlar |
| Ulaşım | İstanbulkart, taksi, akaryakıt, BiTaksi |
| Eğlence | Netflix, Spotify, Steam, sinema |
| Fatura | Elektrik, doğalgaz, internet, telefon |
| Alışveriş | Trendyol, Hepsiburada, Zara, giyim |
| Sağlık | Eczane, doktor, diş hekimi, optik |
| Diğer | Sınıflandırılamayan işlemler |

### Ek B — Koç Ton Kılavuzu

**Yapılacaklar:**
- Gözlem yap, yargılama
- Soru sor, çözüm dayatma
- Küçük olumlu adımları kutla
- Kullanıcının kendi kararını vermesini destekle

**Yapılmayacaklar:**
- "Çok harcıyorsun" gibi doğrudan eleştiri
- "Yapmalısın / Etmelisin" gibi emir cümlesi
- Finansal tavsiye (yatırım, sigorta önerisi)
- Karşılaştırma ("Ortalama kişi bunun yarısını harcıyor")

---

Kullanıcı araştırması ve geliştirme sürecine bağlı olarak güncellenecektir.*
