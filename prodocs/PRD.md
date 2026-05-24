# PRD — Kişisel Harcama Koçu

**Product Requirements Document**  
Sürüm: 1.0 (MVP)  
Son güncelleme: Mayıs 2026

---

## 1. Özet

### 1.1 Problem

Birçok kullanıcı harcamalarını dağınık notlarda, banka uygulamalarında veya hiç takip etmeden yönetiyor. Basit, hızlı ve Türkçe bir araçla **gelir-gider farkını** ve **kategori bazlı harcama alışkanlığını** görmek istiyorlar.

### 1.2 Çözüm

**Kişisel Harcama Koçu**, mobil-first bir finans takip uygulamasıdır. Kullanıcı işlemlerini saniyeler içinde kaydeder; uygulama aylık bakiye, gider dağılımı ve günlük takvim görünümü sunar. **Yapay zeka destekli Finans Koçu**, kullanıcının gerçek harcama verilerine dayanarak kişiselleştirilmiş bütçe tavsiyeleri verir. Veriler önce cihazda tutulur, sonra bulutta yedeklenir.

### 1.3 Ürün vizyonu

> "Paranı nereye harcadığını bilen, AI koçuyla bilinçli harcama kararı veren herkes için en sade kişisel finans uygulaması."

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
| US-01 | E-posta ile kayıt olup giriş yapmak istiyorum, verilerim hesabıma bağlı kalsın. | P0 |
| US-02 | Google ile tek tıkla giriş yapmak istiyorum. | P0 |
| US-03 | Gider/gelir işlemi eklemek istiyorum. | P0 |
| US-04 | Aylık net bakiyemi görmek istiyorum. | P0 |
| US-05 | Harcamalarımı kategorilere göre grafikte görmek istiyorum. | P0 |
| US-06 | Belirli bir günün işlemlerini takvimden görmek istiyorum. | P1 |
| US-07 | İnternet yokken de işlem ekleyebilmek istiyorum; bağlantı gelince senkron olsun. | P0 |
| US-08 | Kendi kategorimi oluşturmak istiyorum. | P1 |
| US-09 | Koyu tema kullanmak istiyorum. | P2 |
| US-10 | Yanlış işlemi silmek istiyorum. | P1 |
| US-11 | AI finans koçuna soru sormak istiyorum; gerçek harcamalarıma göre tavsiye alsın. | P0 |
| US-12 | Aylık AI finans özetini tek tıkla görmek istiyorum. | P0 |

---

## 4. Fonksiyonel gereksinimler (özet)

| Alan | Temel özellikler | Durum |
|------|------------------|-------|
| Kimlik doğrulama | E-posta, Google, şifre sıfırlama, AuthGate | ✅ |
| İşlemler | Gelir/gider, kategori, tarih, not, silme | ✅ |
| Özet & analiz | Aylık bakiye, pasta grafik, kategori dağılımı | ✅ |
| Takvim | Günlük işlem listesi, ay gezintisi | ✅ |
| Kategoriler | 8 varsayılan + özel kategori | ✅ |
| Senkron | Drift (yerel) + Firestore (bulut), offline kuyruk | ✅ |
| AI Finans Koçu | Backend API, Gemini, kişisel bağlam, sohbet geçmişi | ✅ |
| Profil & ayarlar | Tema, manuel sync, çıkış, gizlilik metni | ✅ |

**Post-MVP (planlı):** İşlem/kategori düzenleme, bütçe hedefleri, bildirimler.

---

## 5. Ekran haritası

```
Splash
  └── AuthGate
        ├── Onboarding (ilk açılış)
        ├── Auth (Giriş | Kayıt)
        └── HomeShell
              ├── Özet
              ├── Analiz
              ├── Takvim
              └── Profil
```

Modal: İşlem formu, kategori ekleme, finans koçu sohbeti.

---

## 6. Veri modeli (özet)

- **CategoryItem:** id, userId, name, icon, color, isDefault, synced, updatedAt
- **TransactionItem:** id, userId, amount, type, categoryId, date, note, synced, updatedAt
- **Firestore:** `users/{uid}`, `categories`, `transactions`, `coach_chat`

---

## 7. İş kuralları

1. Net bakiye = gelir − gider (seçili ay).
2. Analiz yalnızca gider işlemlerini kapsar.
3. Senkron çakışmasında daha yeni `updatedAt` kazanır.
4. LLM API anahtarı yalnızca backend'de tutulur.

---

## 8. Başarı metrikleri (MVP sonrası)

| Metrik | Hedef (ilk 3 ay) |
|--------|------------------|
| Kayıt tamamlama | > %70 |
| İlk işlem (24 saat) | > %50 |
| Haftalık aktif / aylık aktif | > %25 |
| Senkron başarı | > %95 |

---

## 9. Referanslar

- [MVP kapsamı](mvp-scope.md)
- [Teknik plan](Plan.md)
- [Tasarım sistemi](DesignSystem.md)
