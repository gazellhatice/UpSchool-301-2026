# Kişisel Harcama Koçu

Gelir ve giderlerini tek yerden takip etmeni sağlayan, Türkçe arayüzlü bir kişisel finans mobil uygulaması. Offline-first yerel depolama ile çalışır; internet olduğunda Firebase Firestore ile senkronize olur.

## Özellikler

- **Kimlik doğrulama** — E-posta/şifre ile kayıt ve giriş, Google ile giriş, şifre sıfırlama
- **Özet ekranı** — Aylık net bakiye, gelir/gider kartları, harcama kullanım oranı, son işlemler
- **İşlem yönetimi** — Gelir/gider ekleme, kategori seçimi, tarih ve not, işlem silme
- **Analiz** — Kategorilere göre aylık gider dağılımı (pasta grafik + liste)
- **Takvim** — Güne göre işlem listesi
- **Kategoriler** — Varsayılan kategoriler + özel kategori ekleme
- **Senkronizasyon** — Drift (SQLite) ↔ Firestore, çevrimdışı çalışma desteği
- **Tema** — Açık / koyu mod

## Teknoloji yığını

| Katman | Teknoloji |
|--------|-----------|
| UI | Flutter 3.x, Material 3, Google Fonts |
| Durum yönetimi | Riverpod |
| Yerel veri | Drift (SQLite) |
| Bulut | Firebase Auth, Cloud Firestore |
| Grafik | fl_chart |
| Takvim | table_calendar |
| Diğer | connectivity_plus, shared_preferences, intl |

## Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.5.4)
- Android Studio / Xcode (mobil derleme için)
- Firebase projesi (Auth + Firestore etkin)

## Kurulum

1. Depoyu klonlayın ve proje klasörüne girin:

```bash
git clone <repo-url>
cd kisisel_harcama_kocu_1
```

2. Bağımlılıkları yükleyin:

```bash
flutter pub get
```

3. Drift kod üretimini çalıştırın (gerekirse):

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Firebase yapılandırmasını tamamlayın (aşağıya bakın).

5. Uygulamayı çalıştırın:

```bash
flutter run
```

Android emülatör veya fiziksel cihaz önerilir. Web için ek Firebase Web uygulaması ve `AppConfig` ayarları gerekir.

## Firebase yapılandırması

1. [Firebase Console](https://console.firebase.google.com) üzerinde proje oluşturun.
2. **Authentication** → E-posta/Parola ve Google sağlayıcılarını etkinleştirin.
3. **Firestore Database** oluşturun (test modunda başlayıp kuralları üretime göre sıkılaştırın).
4. FlutterFire CLI ile yapılandırın:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Bu komut `lib/firebase_options.dart` dosyasını günceller.

5. Android için `android/app/google-services.json` dosyasının mevcut olduğundan emin olun.
6. Google Sign-In (Android) için SHA-1 parmak izini Firebase / Google Cloud OAuth istemcisine ekleyin.

### Firestore veri yapısı

```
users/{userId}
  ├── categories/{categoryId}
  └── transactions/{transactionId}
```

Her kullanıcının verisi kendi `userId` altında tutulur.

## Proje yapısı

```
lib/
├── main.dart                 # Firebase, locale, Riverpod başlatma
├── app.dart                  # MaterialApp, tema
├── firebase_options.dart     # FlutterFire yapılandırması
├── core/                     # Tema, provider'lar, yardımcılar
├── domain/models/            # İşlem, kategori modelleri
├── data/
│   ├── local/                # Drift veritabanı
│   ├── repositories/         # FinanceRepository (sync mantığı)
│   └── mappers/
└── features/
    ├── auth/                 # Giriş, kayıt, AuthGate
    ├── home/                 # Özet, analiz, takvim, ayarlar
    ├── transactions/         # İşlem ekleme formu
    └── categories/           # Kategori ekleme
```

## Platform desteği

| Platform | Durum |
|----------|--------|
| Android | Birincil hedef, tam destek |
| iOS | Flutter standart yapı mevcut |
| Web | Kısıtlı; Google giriş için Web client ID gerekir (`lib/core/config/app_config.dart`) |

## Geliştirme komutları

```bash
flutter analyze          # Statik analiz
flutter test             # Birim/widget testleri
flutter build apk        # Debug/release APK
```

## İlgili dokümanlar

- [MVP_SCOPE.md](MVP_SCOPE.md) — MVP kapsamı ve teslim kriterleri
- [PRD.md](PRD.md) — Ürün gereksinimleri ve kullanıcı hikâyeleri

## Yayın öncesi kontrol listesi

1. Firebase Console’da **Firestore kurallarını** deploy edin: `firebase deploy --only firestore:rules`
2. `AppConstants` içindeki gizlilik URL ve destek e-postasını güncelleyin
3. Android **release imzalama** (`android/app/build.gradle`) yapılandırın
4. Uygulama ikonu `assets/images/splash_logo.png` üzerinden üretilir: `dart run flutter_launcher_icons`
5. `flutter build appbundle` ile Play Store paketini oluşturun

## Lisans

Bu proje özel kullanım içindir (`publish_to: 'none'`).
