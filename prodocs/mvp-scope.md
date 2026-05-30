# MVP Kapsamı — Kişisel Harcama Koçu

Minimum Viable Product için dahil edilenler, bilinçli ertelenenler ve kabul kriterleri.

---

## MVP hedefi

Kullanıcının hesabıyla giriş yapıp gelir/gider kaydı oluşturarak aylık özetini görmesini ve temel harcama analizini yapmasını sağlayan uygulama:

- **Mobil (Android/iOS):** Birincil deneyim — offline-first, alt tab bar, FAB'lar
- **Web:** Aynı hesap ve veriler — responsive (geniş sidebar / dar mobil düzen) + tanıtım sitesi

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
| **Mobil** | 4 sekme shell, FAB, Drift SQLite, offline kuyruk, native Google giriş | ✅ |
| **Web (uygulama)** | Responsive layout, Drift WASM, Firestore senkron, koç | ✅ |
| **Web (pazarlama)** | Landing, Hakkında, İletişim, Gizlilik, İndir (QR) | ✅ |
| **Web (ekstra)** | URL routing, sidebar, CSV export, PWA, koç yan paneli | ✅ |

---

## MVP dışında (post-MVP)

İşlem düzenleme, tekrarlayan işlemler, çoklu para birimi, OCR, bildirimler, kategori silme, Apple Sign-In, otomatik test paketi, gerçek mağaza yayını (şu an demo store URL'leri).

---

## Kabul kriterleri

- [x] E-posta ile kayıt ve giriş çalışıyor
- [x] Google giriş **Android mobilde** çalışıyor
- [x] **Mobil:** 4 sekme alt bar + FAB ile gezinme çalışıyor
- [x] **Mobil:** Offline işlem eklenip online senkron oluyor
- [x] Gelir/gider ekleme özet ekranını güncelliyor
- [x] Analiz sekmesinde pasta grafik görünüyor
- [x] Takvimde günlük işlemler listeleniyor
- [x] Offline işlem kalıcı; online senkron çalışıyor
- [x] AI koç backend'e bağlanıp yanıt üretiyor
- [x] Web'de (Chrome) giriş yapılıp aynı hesap verileri görünüyor
- [x] Geniş tarayıcı penceresinde sidebar layout çalışıyor
- [x] Tanıtım sayfaları (`/`, `/indir`, `/giris`) açılıyor
- [x] Web'de Profil → CSV indirme çalışıyor
- [x] Backend + web **canlı deploy** tamamlandı
- [x] **Demo video** (≤5 dk) hazırlandı

---

## Sürüm

| Alan | Değer |
|------|--------|
| MVP sürümü | 1.0.0 |
| Son güncelleme | Mayıs 2026 |
