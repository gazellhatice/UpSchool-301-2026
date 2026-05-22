import 'package:flutter/material.dart';

/// Tema duyarlı renk paleti.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.gradientHero,
    required this.heroTitleColors,
    required this.glassSurface,
    required this.glassBorder,
  });

  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> gradientHero;
  final List<Color> heroTitleColors;
  final Color glassSurface;
  final Color glassBorder;

  static const dark = AppPalette(
    background: Color(0xFF05070D),
    surface: Color(0xFF12151F),
    surfaceLight: Color(0xFF1C2130),
    border: Color(0xFF2A3145),
    textPrimary: Color(0xFFF4F6FB),
    textSecondary: Color(0xFF9AA3B8),
    gradientHero: [
      Color(0xFF0A1024),
      Color(0xFF121A3A),
      Color(0xFF05070D),
    ],
    heroTitleColors: [Colors.white, Color(0xFF5B8CFF), Color(0xFF3DDC97)],
    glassSurface: Color(0xB812151F),
    glassBorder: Color(0x14FFFFFF),
  );

  static const light = AppPalette(
    background: Color(0xFFF5F7FC),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEEF2FA),
    border: Color(0xFFD8DEE9),
    textPrimary: Color(0xFF0F1419),
    textSecondary: Color(0xFF5C667A),
    gradientHero: [
      Color(0xFFE8EEFF),
      Color(0xFFF0F4FF),
      Color(0xFFF5F7FC),
    ],
    heroTitleColors: [Color(0xFF0F1419), Color(0xFF3D5AFE), Color(0xFF00A67E)],
    glassSurface: Color(0xE6FFFFFF),
    glassBorder: Color(0x1A000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    List<Color>? gradientHero,
    List<Color>? heroTitleColors,
    Color? glassSurface,
    Color? glassBorder,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      gradientHero: gradientHero ?? this.gradientHero,
      heroTitleColors: heroTitleColors ?? this.heroTitleColors,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
