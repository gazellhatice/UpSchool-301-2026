# Design System — Kişisel Harcama Koçu

Modern fintech estetiği; gradient arka planlar, cam efektli kartlar, mor-indigo birincil renk.

---

## Renk Paleti

### Birincil (Brand)

| Token | Hex | Kullanım |
|-------|-----|----------|
| `primary` | `#5B8CFF` | Butonlar, linkler, vurgular |
| `primaryGlow` | `#7B5CFF` | Gradient uçları |
| `coachPrimary` | `#6C63FF` | AI Koç FAB, sohbet balonları |
| `coachAccent` | `#48CAE4` | Koç gradient ikinci rengi |

### Semantik

| Token | Hex | Kullanım |
|-------|-----|----------|
| `accent` / gelir | `#3DDC97` | Gelir kartları, pozitif bakiye |
| `accentWarm` | `#FFB547` | Uyarı, harcama oranı |
| `danger` / gider | `#FF6B7A` | Gider kartları, silme, hata |

### Yüzey (Dark Mode — varsayılan odak)

| Token | Hex | Kullanım |
|-------|-----|----------|
| `background` | `#05070D` | Scaffold arka plan |
| `surface` | `#12151F` | Kartlar, nav bar |
| `surfaceLight` | `#1C2130` | Input, ikincil yüzey |
| `border` | `#2A3145` | Kart kenarlıkları |

### Metin

| Token | Hex | Kullanım |
|-------|-----|----------|
| `textPrimary` | `#F4F6FB` | Başlıklar, gövde |
| `textSecondary` | `#9AA3B8` | Alt metin, etiketler |

### Gradientler

```dart
gradientHero:  [#0A1024 → #121A3A → #05070D]  // Arka plan
gradientCard:  [#3D5AFE → #7C4DFF → #00C9A7]  // Hero kart
gradientIncome:[#00C9A7 → #3DDC97]            // Gelir
gradientExpense:[#FF6B7A → #FFB547]           // Gider
coachGradient: [#6C63FF → #48CAE4]            // AI Koç
```

---

## Tipografi

**Font ailesi:** Plus Jakarta Sans (Google Fonts)

| Stil | Weight | Kullanım |
|------|--------|----------|
| `headlineSmall` | 800 | Karşılama, bakiye |
| `titleLarge` | 800 | Boş durum başlıkları |
| `titleMedium` | 700–800 | AppBar, kart başlıkları |
| `titleSmall` | 700 | Alt bölüm başlıkları |
| `bodyMedium` | 400 | Gövde metni, sohbet |
| `bodySmall` | 400 | İkincil bilgi |
| `labelSmall` | 600 | Badge, chip |

**Letter-spacing:** Başlıklarda `-0.5` ile `-0.6` (sıkı, modern)

---

## Spacing & Radius

| Token | Değer | Kullanım |
|-------|-------|----------|
| Screen padding | `20px` | Liste kenar boşlukları |
| Card padding | `16–20px` | GlassCard içi |
| Section gap | `16–24px` | Bölümler arası |
| Item gap | `10–12px` | Liste elemanları |
| Border radius (card) | `20px` | GlassCard, Material Card |
| Border radius (button) | `20px` | Input, chip |
| Border radius (bubble) | `18px` | Sohbet balonları |
| Border radius (icon box) | `8–10px` | Koç avatar kutusu |

---

## Bileşen Kuralları

### GlassCard

- Yarı saydam yüzey + blur hissi
- `borderRadius: 20`
- İnce `border` rengi (`palette.border`)
- İç padding minimum `16px`

### GradientBackground

- Tüm ana ekranların arka planı
- `gradientHero` ile derinlik

### NavigationBar

- 4 sekme: Özet, Analiz, Takvim, Profil
- `IndexedStack` ile state korunur
- Indicator: `primary` %20 opacity

### FAB (Floating Action Button)

| FAB | Renk | Görünürlük |
|-----|------|------------|
| İşlem ekle (+) | Primary gradient | Özet + Takvim sekmeleri |
| Finans Koçu (✨) | `#6C63FF` | Her zaman |

### MonthSelector

- Sol/sağ ok ile ay değiştirme
- `tr_TR` locale ile ay adı

### ConfirmDialog

- Destructive işlemler: kırmızı onay butonu
- İptal: TextButton

### Coach Chat

- Kullanıcı balonu: `#6C63FF` dolgu, beyaz metin
- Asistan balonu: `surface` / beyaz, gölge
- Typing indicator: 3 animasyonlu nokta
- Suggestion chips: `%10 primary` arka plan

### CoachInsightCard

- Dashboard'da AI analiz kartı
- "Analiz Et" → backend `/analyze`
- "Koça Sor" → tam sohbet ekranı

---

## İkonografi

- **Material Icons Rounded** varyantı
- Gelir: `trending_up_rounded`
- Gider: `trending_down_rounded`
- Koç: `auto_awesome_rounded`
- Analiz: `insights_rounded`
- Kategori: kullanıcı seçimi (Material icon codePoint)

---

## Tema Modları

| Mod | Scaffold | Kart | Metin |
|-----|----------|------|-------|
| Dark | `#05070D` | `#12151F` | `#F4F6FB` |
| Light | `#F5F5FF` | `#FFFFFF` | `#1A1A2E` |

Tercih `SharedPreferences` ile kalıcı.

---

## Erişilebilirlik

- Material 3 bileşenleri
- Minimum kontrast oranı: açık/koyu modda test edildi
- Dokunma hedefleri: minimum 44×44 logical px (FAB, IconButton)
- `SnackBar` floating davranışı

---

## Referans Dosyalar

- `frontend/lib/core/theme/app_colors.dart`
- `frontend/lib/core/theme/app_palette.dart`
- `frontend/lib/core/theme/app_theme.dart`
- `frontend/lib/core/widgets/glass_card.dart`
- `frontend/lib/core/widgets/gradient_background.dart`
