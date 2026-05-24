# MVP Kapsamı — Kişisel Harcama Koçu

Minimum Viable Product için dahil edilenler, bilinçli ertelenenler ve kabul kriterleri.

---

## MVP hedefi

Kullanıcının hesabıyla giriş yapıp gelir/gider kaydı oluşturarak aylık özetini görmesini ve temel harcama analizini yapmasını sağlayan, çevrimdışı da kullanılabilen bir mobil uygulama.

---

## MVP kapsamında

| Alan | Özellikler | Durum |
|------|------------|-------|
| Kimlik | E-posta, Google, şifre sıfırlama, çıkış | ✅ |
| İşlemler | Gelir/gider, kategori, tarih, not, silme | ✅ |
| Kategoriler | 8 varsayılan + özel kategori | ✅ |
| Ekranlar | Özet, Analiz, Takvim, Profil | ✅ |
| Senkron | Drift + Firestore, offline kuyruk | ✅ |
| AI Koç | Backend API, sohbet, aylık analiz | ✅ |
| UX | tr_TR, açık/koyu tema, onboarding | ✅ |

---

## MVP dışında (post-MVP)

İşlem düzenleme, bütçe limiti, tekrarlayan işlemler, çoklu para birimi, OCR, bildirimler, kategori silme, export, Apple Sign-In, otomatik test paketi.

---

## Kabul kriterleri

- [ ] E-posta ile kayıt ve giriş çalışıyor
- [ ] Google giriş Android'de çalışıyor
- [ ] Gelir/gider ekleme özet ekranını güncelliyor
- [ ] Analiz sekmesinde pasta grafik görünüyor
- [ ] Takvimde günlük işlemler listeleniyor
- [ ] Offline işlem kalıcı; online senkron çalışıyor
- [ ] AI koç backend'e bağlanıp yanıt üretiyor

---

## Sürüm

| Alan | Değer |
|------|--------|
| MVP sürümü | 1.0.0 |
| Son güncelleme | Mayıs 2026 |
