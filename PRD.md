# PRD — Kişisel Harcama Koçu

**Product Requirements Document**  
Sürüm: 1.0 (MVP)  
Durum: Uygulama geliştirilmiş; bu belge ürün gereksinimlerini ve mevcut implementasyonu dokümante eder.

---

## 1. Özet

### 1.1 Problem

Birçok kullanıcı harcamalarını dağınık notlarda, banka uygulamalarında veya hiç takip etmeden yönetiyor. Basit, hızlı ve Türkçe bir araçla **gelir-gider farkını** ve **kategori bazlı harcama alışkanlığını** görmek istiyorlar.

### 1.2 Çözüm

**Kişisel Harcama Koçu**, mobil-first bir finans takip uygulamasıdır. Kullanıcı işlemlerini saniyeler içinde kaydeder; uygulama aylık bakiye, gider dağılımı ve günlük takvim görünümü sunar. Veriler önce cihazda tutulur, sonra bulutta yedeklenir.

### 1.3 Ürün vizyonu

> “Paranı nereye harcadığını bilen, bilinçli harcama kararı veren herkes için en sade kişisel finans koçu.”

---

## 2. Hedef kitle

| Persona | İhtiyaç |
|---------|---------|
| **Genç profesyonel (22–35)** | Maaş + günlük harcamayı hızlı kaydetmek, ay sonu bakiyesini görmek |
| **Öğrenci** | Sınırlı bütçeyle kategori bazlı harcama farkındalığı |
| **Serbest çalışan** | Düzensiz gelir/gider akışını tek yerde toplamak |

**Birincil pazar:** Türkiye (Türkçe UI, TRY para birimi).

---

## 3. Kullanıcı hikâyeleri

| ID | Hikâye | Öncelik |
|----|--------|---------|
| US-01 | Kullanıcı olarak e-posta ile kayıt olup giriş yapmak istiyorum, böylece verilerim hesabıma bağlı kalır. | P0 |
| US-02 | Kullanıcı olarak Google ile tek tıkla giriş yapmak istiyorum, böylece şifre hatırlamak zorunda kalmam. | P0 |
| US-03 | Kullanıcı olarak gider/gelir işlemi eklemek istiyorum, böylece harcamalarım kayıt altında olsun. | P0 |
| US-04 | Kullanıcı olarak aylık net bakiyemi görmek istiyorum, böylece ay sonunda ne kadar kaldığımı bilirim. | P0 |
| US-05 | Kullanıcı olarak harcamalarımı kategorilere göre grafikte görmek istiyorum, böylece en çok nereye harcadığımı anlarım. | P0 |
| US-06 | Kullanıcı olarak belirli bir günün işlemlerini takvimden görmek istiyorum, böylece o gün ne harcadığımı hatırlarım. | P1 |
| US-07 | Kullanıcı olarak internet yokken de işlem ekleyebilmek istiyorum, bağlantı gelince verilerim senkron olsun. | P0 |
| US-08 | Kullanıcı olarak kendi kategorimi oluşturmak istiyorum, böylece harcama tiplerim bana özel olsun. | P1 |
| US-09 | Kullanıcı olarak koyu tema kullanmak istiyorum, gece rahat kullanayım. | P2 |
| US-10 | Kullanıcı olarak yanlış işlemi silmek istiyorum, veri setim temiz kalsın. | P1 |

---

## 4. Fonksiyonel gereksinimler

### 4.1 Kimlik doğrulama (FR-AUTH)

| ID | Gereksinim | Durum |
|----|------------|--------|
| FR-AUTH-01 | E-posta + şifre ile kayıt (min. 6 karakter) | ✅ |
| FR-AUTH-02 | E-posta + şifre ile giriş | ✅ |
| FR-AUTH-03 | Google OAuth ile giriş | ✅ |
| FR-AUTH-04 | Şifremi unuttum → sıfırlama e-postası | ✅ |
| FR-AUTH-05 | Oturum durumuna göre AuthGate yönlendirmesi | ✅ |
| FR-AUTH-06 | Firebase başlatma hatasında kullanıcıya bilgi | ✅ |
| FR-AUTH-07 | Türkçe hata mesajları | ✅ |

### 4.2 İşlemler (FR-TX)

| ID | Gereksinim | Durum |
|----|------------|--------|
| FR-TX-01 | İşlem tipi: gelir veya gider | ✅ |
| FR-TX-02 | Pozitif sayısal tutar zorunluluğu | ✅ |
| FR-TX-03 | Kategori seçimi zorunlu | ✅ |
| FR-TX-04 | Tarih seçimi (geçmiş / gelecek 1 yıl) | ✅ |
| FR-TX-05 | İsteğe bağlı not alanı | ✅ |
| FR-TX-06 | İşlem silme | ✅ |
| FR-TX-07 | İşlem düzenleme | ❌ (post-MVP) |

### 4.3 Özet ve raporlama (FR-DASH)

| ID | Gereksinim | Durum |
|----|------------|--------|
| FR-DASH-01 | Seçili ay için toplam gelir, gider, net bakiye | ✅ |
| FR-DASH-02 | Gelire göre harcama kullanım yüzdesi (progress) | ✅ |
| FR-DASH-03 | Son işlemler listesi (en fazla 12) | ✅ |
| FR-DASH-04 | Kategori bazlı gider yüzdesi ve tutar (analiz sekmesi) | ✅ |
| FR-DASH-05 | Pasta grafik (fl_chart) | ✅ |
| FR-DASH-06 | Takvimde gün seçimi → günlük işlem listesi | ✅ |

### 4.4 Kategoriler (FR-CAT)

| ID | Gereksinim | Durum |
|----|------------|--------|
| FR-CAT-01 | İlk kullanımda 8 varsayılan kategori | ✅ |
| FR-CAT-02 | Özel kategori: ad, Material ikon, renk | ✅ |
| FR-CAT-03 | İşlem tipine göre kategori filtresi | ✅ |
| FR-CAT-04 | Kategori silme/düzenleme | ❌ (post-MVP) |

### 4.5 Veri ve senkron (FR-SYNC)

| ID | Gereksinim | Durum |
|----|------------|--------|
| FR-SYNC-01 | Tüm finans verisi kullanıcıya özel (`userId`) | ✅ |
| FR-SYNC-02 | Yerel Drift veritabanı | ✅ |
| FR-SYNC-03 | Firestore `categories` ve `transactions` alt koleksiyonları | ✅ |
| FR-SYNC-04 | `synced` bayrağı ile push kuyruğu | ✅ |
| FR-SYNC-05 | Pull sırasında `updatedAt` karşılaştırması | ✅ |
| FR-SYNC-06 | Manuel senkron tetikleme (ayarlar) | ✅ |
| FR-SYNC-07 | Bağlantı yokken yazma; online olunca otomatik sync denemesi | ✅ |

### 4.6 Ayarlar (FR-SET)

| ID | Gereksinim | Durum |
|----|------------|--------|
| FR-SET-01 | Profil: ad, e-posta, avatar | ✅ |
| FR-SET-02 | Açık/koyu tema, kalıcı tercih | ✅ |
| FR-SET-03 | Kategori listesi görüntüleme | ✅ |
| FR-SET-04 | Çıkış yap | ✅ |

---

## 5. Fonksiyonel olmayan gereksinimler

| ID | Gereksinim | Hedef |
|----|------------|--------|
| NFR-01 | Uygulama açılışı | Splash → AuthGate < 3 sn (Firebase hazır ortamda) |
| NFR-02 | İşlem kaydetme | Yerel yazma < 500 ms algılanan gecikme |
| NFR-03 | Dil / locale | `tr_TR` tarih ve para formatı |
| NFR-04 | Erişilebilirlik | Material bileşenleri, yeterli kontrast (açık/koyu) |
| NFR-05 | Güvenlik | Firestore kuralları: kullanıcı yalnızca kendi `userId` verisine erişir |
| NFR-06 | Gizlilik | Finans verisi üçüncü taraf analitiğe gönderilmez (MVP) |
| NFR-07 | Platform | Android birincil; iOS/Web ikincil |

---

## 6. Bilgi mimarisi

### 6.1 Ekran haritası

```
Splash
  └── AuthGate
        ├── AuthScreen (Giriş | Kayıt)
        └── HomeShell
              ├── Özet (Dashboard)
              ├── Analiz (Stats)
              ├── Takvim (Calendar)
              └── Profil (Settings)
```

**Modal / sheet:** İşlem ekleme (`TransactionFormSheet`), Kategori ekleme (`AddCategorySheet`).

### 6.2 Veri modeli

**CategoryItem (domain)**

- `id`, `userId`, `name`, `icon`, `color`, `isDefault`, `synced`, `updatedAt`

**TransactionItem (domain)**

- `id`, `userId`, `amount`, `type` (gelir/gider), `categoryId`, `date`, `note`, `synced`, `updatedAt`
- İlişki: `category` (join ile)

**Firestore şeması**

```json
// users/{uid}
{
  "email": "string",
  "displayName": "string",
  "photoUrl": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// users/{uid}/categories/{categoryId}
{
  "name": "string",
  "iconCodePoint": "int",
  "colorValue": "int",
  "isDefault": "bool",
  "updatedAt": "timestamp"
}

// users/{uid}/transactions/{transactionId}
{
  "amount": "number",
  "type": "int",
  "categoryId": "string",
  "date": "timestamp",
  "note": "string",
  "updatedAt": "timestamp"
}
```

---

## 7. İş kuralları

1. **Bakiye:** `net = toplam_gelir - toplam_gider` (seçili ay).
2. **Kullanım oranı:** `gider / gelir` (gelir > 0 ise); aksi halde 0.
3. **Analiz:** Yalnızca gider işlemleri kategori istatistiğine dahil edilir.
4. **Gelir kategorileri:** Formda Maaş, Ek Gelir ve özel kategoriler; gider formunda bunlar gizlenir.
5. **Senkron çakışması:** Aynı `id` için uzaktaki `updatedAt` daha yeniyse yerel üzerine yazılır.
6. **Silme:** Yerel silme her zaman uygulanır; online ise Firestore dokümanı da silinir.

---

## 8. Tasarım ilkeleri

- **Modern fintech estetiği:** Gradient arka plan, cam efektli kartlar (`GlassCard`), yuvarlatılmış köşeler.
- **Renk semantiği:** Gelir → yeşil tonlar; gider → kırmızı; birincil aksiyon → mor/indigo gradient.
- **Navigasyon:** Alt `NavigationBar` ile 4 sekme; işlem ekleme FAB yalnızca Özet sekmesinde.
- **Tipografi:** Google Fonts (tema üzerinden).

---

## 9. Başarı metrikleri (MVP sonrası ölçüm)

| Metrik | Açıklama | Hedef (ilk 3 ay) |
|--------|----------|------------------|
| Kayıt tamamlama | Kayıt başlayan / bitiren | > %70 |
| İlk işlem (D1) | Kayıt sonrası 24 saat içinde ≥1 işlem | > %50 |
| Haftalık aktif (WAU/MAU) | 7 günde en az 1 açılış | > %25 |
| Ortalama işlem/aktif kullanıcı/hafta | Engagement | ≥ 3 |
| Senkron başarı oranı | Manuel/otomatik sync hatasız | > %95 |

---

## 10. Riskler ve mitigasyon

| Risk | Etki | Mitigasyon |
|------|------|------------|
| Firebase yapılandırma eksik | Giriş çalışmaz | README kurulum adımları, `firebase_options` |
| Firestore kuralları gevşek | Veri sızıntısı | Üretimde kullanıcı bazlı rules |
| Sync çakışması | Veri kaybı algısı | `updatedAt` stratejisi; ileride conflict UI |
| Kategori silinememesi | Kullanıcı kirliliği | Post-MVP düzenleme/silme |
| Web Google OAuth | Giriş başarısız | Android öncelikli test, AppConfig dokümantasyonu |

---

## 11. Yol haritası özeti

| Faz | Odak | Zaman çerçevesi (öneri) |
|-----|------|-------------------------|
| **MVP (v1.0)** | Kayıt, işlem, özet, analiz, takvim, offline sync | Mevcut |
| **v1.1** | İşlem/kategori düzenleme, ay seçici UI | +4–6 hafta |
| **v1.2** | Bütçe hedefleri, bildirimler | +6–8 hafta |
| **v2.0** | Export, gelişmiş raporlar, opsiyonel premium | +3 ay |

---

## 12. Onay ve referanslar

| Rol | Sorumluluk |
|-----|------------|
| Ürün sahibi | Kapsam onayı, öncelik sırası |
| Geliştirme | Teknik uygulama, Firebase kurulumu |
| QA | MVP kabul kriterleri ([MVP_SCOPE.md](MVP_SCOPE.md)) |

**Teknik referans:** [README.md](README.md)  
**Kapsam referansı:** [MVP_SCOPE.md](MVP_SCOPE.md)
