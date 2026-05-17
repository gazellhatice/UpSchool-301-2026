# MVP Kapsamı — Kişisel Harcama Koçu

Bu belge, **Minimum Viable Product (MVP)** için neyin dahil edildiğini, neyin bilinçli olarak ertelendiğini ve teslim kriterlerini tanımlar. Kapsam, mevcut kod tabanıyla uyumludur.

---

## MVP hedefi

Kullanıcının **hesabıyla giriş yapıp**, **gelir/gider kaydı oluşturarak**, **aylık özetini görmesini** ve **temel harcama analizini** yapmasını sağlayan, çevrimdışı da kullanılabilen bir mobil uygulama sunmak.

**Başarı tanımı:** Tek kullanıcı, bir ay boyunca işlemlerini ekleyebilir; özet, analiz ve takvim ekranları tutarlı veri gösterir; cihaz yeniden açıldığında veri kaybolmaz; internet geldiğinde bulutla eşitlenir.

---

## MVP kapsamında (dahil)

### 1. Kimlik ve oturum

| Özellik | Durum |
|---------|--------|
| E-posta ile kayıt | ✅ |
| E-posta ile giriş | ✅ |
| Google ile giriş (Android / Web) | ✅ |
| Şifre sıfırlama e-postası | ✅ |
| Çıkış yapma | ✅ |
| Kullanıcı profil dokümanı (`users/{uid}`) | ✅ |

### 2. İşlem yönetimi

| Özellik | Durum |
|---------|--------|
| Gelir / gider ekleme | ✅ |
| Tutar, kategori, tarih, not | ✅ |
| İşlem silme (özet listesinden) | ✅ |
| Türk Lirası formatı (`₺`) | ✅ |

### 3. Kategoriler

| Özellik | Durum |
|---------|--------|
| İlk girişte varsayılan kategoriler (8 adet) | ✅ |
| Özel kategori ekleme (ad, ikon, renk) | ✅ |
| Gelir işleminde gelir kategorileri filtresi | ✅ |
| Gider işleminde gider kategorileri filtresi | ✅ |

**Varsayılan kategoriler:** Maaş, Ek Gelir, Yemek, Ulaşım, Kira, Eğlence, Sağlık, Diğer.

### 4. Ana ekranlar (4 sekme)

| Sekme | İçerik | Durum |
|-------|--------|--------|
| Özet | Net bakiye, gelir/gider, son 12 işlem, FAB ile işlem ekle | ✅ |
| Analiz | Aylık gider pasta grafiği, kategori listesi | ✅ |
| Takvim | Ay görünümü, seçilen günün işlemleri | ✅ |
| Profil | Kullanıcı bilgisi, senkron, tema, kategoriler, çıkış | ✅ |

### 5. Veri ve senkronizasyon

| Özellik | Durum |
|---------|--------|
| Yerel SQLite (Drift) | ✅ |
| Firestore push/pull | ✅ |
| Çevrimdışı okuma/yazma | ✅ |
| Manuel senkron butonu | ✅ |
| `updatedAt` ile çakışma çözümü (son yazılan kazanır) | ✅ |

### 6. UX / teknik

| Özellik | Durum |
|---------|--------|
| Türkçe tarih/sayı formatı (`tr_TR`) | ✅ |
| Açık / koyu tema | ✅ |
| Splash + AuthGate akışı | ✅ |
| Gradient / glass kart tasarım dili | ✅ |

---

## MVP dışında (bilinçli ertelenen)

Aşağıdakiler **MVP sonrası** değerlendirilir:

| Özellik | Gerekçe |
|---------|---------|
| İşlem düzenleme | MVP’de sil + yeniden ekle yeterli |
| Bütçe / harcama limiti tanımlama | Özet ekranda sadece gelire göre kullanım yüzdesi var |
| Tekrarlayan işlemler | Karmaşıklık artırır |
| Çoklu para birimi | Tek para birimi (TRY) yeterli |
| Banka / SMS / fiş OCR entegrasyonu | Kapsam dışı |
| Bildirimler ve hatırlatıcılar | MVP odak: kayıt + görüntüleme |
| Kategori silme / düzenleme | Sadece ekleme mevcut |
| Aile / paylaşımlı hesap | Tek kullanıcı modeli |
| Rapor dışa aktarma (PDF, CSV) | Sonraki faz |
| Apple Sign-In | Sadece Google + e-posta |
| Gelişmiş güvenlik (2FA, biyometrik kilit) | Sonraki faz |
| Unit / entegrasyon test paketi | MVP manuel test ile doğrulanır |

---

## Kabul kriterleri (MVP teslimi)

### Kimlik

- [ ] Yeni kullanıcı e-posta ile kayıt olup ana ekrana ulaşabiliyor.
- [ ] Mevcut kullanıcı giriş yapıp oturumu koruyor (uygulama yeniden açılınca).
- [ ] Google ile giriş Android’de çalışıyor (SHA-1 yapılandırılmış ortamda).

### İşlemler

- [ ] Gider işlemi eklendiğinde özet ekranında gider ve bakiye güncelleniyor.
- [ ] Gelir işlemi eklendiğinde net bakiye artıyor.
- [ ] İşlem silindiğinde listeden ve özetten kalkıyor.

### Görselleştirme

- [ ] En az bir gider kategorisi varken analiz sekmesinde pasta grafik görünüyor.
- [ ] Takvimde işlem olan gün seçildiğinde o güne ait kayıtlar listeleniyor.

### Veri dayanıklılığı

- [ ] Uçak modunda işlem eklenebiliyor; uygulama kapanıp açılınca veri duruyor.
- [ ] İnternet açıldığında manuel senkron veya otomatik push ile Firestore’da kayıt oluşuyor.

### Ayarlar

- [ ] Tema değişimi kalıcı (SharedPreferences).
- [ ] Yeni kategori eklenebiliyor ve işlem formunda seçilebiliyor.

---

## MVP sınırları ve bilinen kısıtlar

- **Ay seçici:** Özet/analiz şu an `selectedMonthProvider` ile ay destekler; UI’da ay değiştirme her ekranda görünür olmayabilir — MVP’de mevcut ay odaklı kullanım yeterli kabul edilir.
- **Senkron:** Tam çift yönlü gerçek zamanlı dinleyici yok; periyodik/manuel sync modeli.
- **Güvenlik kuralları:** Firestore kuralları geliştirici sorumluluğunda; üretimde `users/{userId}` yalnızca sahibine açık olmalı.
- **Web:** İkincil platform; mobil öncelikli test.

---

## Sonraki faz önerisi (post-MVP)

1. İşlem düzenleme + kategori düzenleme/silme  
2. Aylık bütçe hedefi ve uyarılar  
3. Ay/yıl filtre UI’si (tüm sekmelerde tutarlı)  
4. Firestore security rules + otomatik sync iyileştirmesi  
5. Widget / bildirim (günlük hatırlatma)  
6. Test coverage ve CI pipeline  

---

## Sürüm

| Alan | Değer |
|------|--------|
| MVP sürümü | 1.0.0 |
| Son güncelleme | Mayıs 2026 |
| Kod paketi | `kisisel_harcama_kocu_1` |
