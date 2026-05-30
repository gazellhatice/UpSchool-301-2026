# PRD — Kişisel Harcama Koçu

**Product Requirements Document**  
Sürüm: 1.0 (MVP)  
Son güncelleme: Mayıs 2026

---

## 1. Özet

### 1.1 Problem

Birçok kullanıcı harcamalarını dağınık notlarda, banka uygulamalarında veya hiç takip etmeden yönetiyor. Basit, hızlı ve Türkçe bir araçla **gelir-gider farkını** ve **kategori bazlı harcama alışkanlığını** görmek istiyorlar.

### 1.2 Çözüm

**Kişisel Harcama Koçu**, mobil-first bir finans takip uygulamasıdır; **aynı Flutter kod tabanından web sürümü** de sunulur. Kullanıcı işlemlerini saniyeler içinde kaydeder; uygulama aylık bakiye, gider dağılımı ve günlük takvim görünümü sunar. **Yapay zeka destekli Finans Koçu**, kullanıcının gerçek harcama verilerine dayanarak kişiselleştirilmiş bütçe tavsiyeleri verir. Veriler önce cihazda (mobil) veya tarayıcıda (web) tutulur, sonra bulutta yedeklenir.

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
| US-13 | Aynı hesapla tarayıcıdan (web) giriş yapıp mobildeki verilerimi görmek istiyorum. | P0 |
| US-14 | Geniş ekranda (masaüstü tarayıcı) sidebar ile rahat gezinebilmek istiyorum. | P1 |
| US-15 | Tanıtım sitesinden uygulamayı anlayıp kayıt olmak istiyorum. | P1 |
| US-16 | Mobil uygulamayı indirmek için QR veya mağaza linki görmek istiyorum. | P2 |
| US-17 | Web'de işlemlerimi CSV olarak indirmek istiyorum. | P1 |

---

## 4. Fonksiyonel gereksinimler (özet)

### 4.1 Ortak (mobil + web)

| Alan | Temel özellikler | Durum |
|------|------------------|-------|
| Kimlik doğrulama | E-posta, Google, şifre sıfırlama, AuthGate, onboarding | ✅ |
| İşlemler | Gelir/gider, kategori, tarih, not, silme | ✅ |
| Özet & analiz | Aylık bakiye, pasta grafik, kategori dağılımı, AI özet kartı | ✅ |
| Takvim | Günlük işlem listesi, ay gezintisi, ısı haritası | ✅ |
| Kategoriler | 8 varsayılan + özel kategori | ✅ |
| Senkron | Drift (yerel) + Firestore (bulut) | ✅ |
| AI Finans Koçu | Backend API, Gemini, kişisel bağlam, sohbet geçmişi | ✅ |
| Profil & ayarlar | Tema, manuel sync, çıkış, gizlilik metni | ✅ |
| Platform | Android, iOS, Web — **tek Flutter kod tabanı** | ✅ |

### 4.2 Mobil (Android / iOS)

| Alan | Özellik | Durum |
|------|---------|-------|
| UI kabuğu | `HomeShellMobile` — alt **4 sekmeli** NavigationBar | ✅ |
| Hızlı işlem | FAB: Finans Koçu + İşlem ekle (Özet/Takvim) | ✅ |
| Yerel veri | Drift **SQLite** (dosya tabanlı), offline-first | ✅ |
| Offline | Uçak modunda işlem ekleme; online olunca senkron | ✅ |
| Google giriş | Native Google Sign-In (SHA-1 Firebase) | ✅ |
| Geliştirme | `run_emulator.ps1`, `adb reverse` (backend localhost) | ✅ |

### 4.3 Web (tarayıcı)

| Alan | Özellik | Durum |
|------|---------|-------|
| UI kabuğu (geniş) | `HomeShellWeb` + `WebAppSidebar` (≥900px) | ✅ |
| UI kabuğu (dar) | Dar pencerede **mobil shell** (alt tab bar + FAB) | ✅ |
| Yerel veri | Drift **WebAssembly** (`sqlite3.wasm`) | ✅ |
| Tanıtım sitesi | Landing, Hakkında, İletişim, Gizlilik, İndir, `/giris` | ✅ |
| URL routing | `/uygulama/{ozet,analiz,takvim,profil}` — yenilemede sekme korunur | ✅ |
| Web ekstra | CSV export, PWA manifest, klavye kısayolları, koç yan paneli | ✅ |
| Geliştirme | `run_chrome.ps1`, `deploy_web.ps1` | ✅ |

**Post-MVP (planlı):** İşlem/kategori düzenleme, bütçe hedefleri, bildirimler.

---

## 5. Ekran haritası

### 5.1 Tanıtım sitesi (herkese açık — web)

```
/                 Landing (hero, özellikler, canlı önizleme)
/hakkimizda       Hakkında
/iletisim         İletişim formu
/gizlilik         Gizlilik özeti
/indir            Mobil indirme (QR + Play / App Store / APK)
/giris            Giriş | Kayıt (marka paneli + form)
```

Navbar: Ana Sayfa · Hakkında · Uygulamayı indir · İletişim · Giriş yap / Kayıt ol

### 5.2 Uygulama (giriş sonrası — mobil + web)

```
Splash
  └── AuthGate
        ├── Onboarding (ilk açılış)
        ├── Auth → /giris
        └── HomeShell (≥900px → web sidebar; <900px → mobil tab bar)
              ├── Özet      (/uygulama/ozet)
              ├── Analiz    (/uygulama/analiz)
              ├── Takvim    (/uygulama/takvim)
              └── Profil    (/uygulama/profil — web'de sidebar alt kartından)
```

### 5.3 Mobil layout (Android / iOS ve dar web)

- Kabuk: `home_shell_mobile.dart`
- Alt **NavigationBar:** Özet · Analiz · Takvim · **Profil** (4 sekme)
- Sağ altta **FAB:** Finans Koçu (mor) + İşlem ekle (Özet/Takvim sekmelerinde)
- Ortak sekme içi header: `AppScreenHeader` (logo + koç + profil avatarı)
- Koç: tam ekran modal / sheet (`CoachChatScreen`)
- Veri: Drift SQLite, offline kuyruk

### 5.4 Web layout (geniş tarayıcı, ≥900px)

- Kabuk: `home_shell_web.dart` + `web_app_sidebar.dart`
- Sidebar menü: Özet · Analiz · Takvim (Profil → alt kullanıcı kartı)
- Üst: `AppShellTopBar` (breadcrumb, ay seçici, senkron, koç)
- Koç: sağda **yan panel** (400px) veya tam ekran
- URL: `go_router` ile sekme adres çubuğunda kalır

### 5.5 Ortak modaller

İşlem formu, kategori ekleme, finans koçu sohbeti, profil düzenleme — **mobil ve web'de aynı widget'lar**.

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
