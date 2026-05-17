import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF05070D);
  static const surface = Color(0xFF12151F);
  static const surfaceLight = Color(0xFF1C2130);
  static const border = Color(0xFF2A3145);

  static const primary = Color(0xFF5B8CFF);
  static const primaryGlow = Color(0xFF7B5CFF);
  static const accent = Color(0xFF3DDC97);
  static const accentWarm = Color(0xFFFFB547);
  static const danger = Color(0xFFFF6B7A);

  static const textPrimary = Color(0xFFF4F6FB);
  static const textSecondary = Color(0xFF9AA3B8);

  static const gradientHero = [
    Color(0xFF0A1024),
    Color(0xFF121A3A),
    Color(0xFF05070D),
  ];

  static const gradientCard = [
    Color(0xFF3D5AFE),
    Color(0xFF7C4DFF),
    Color(0xFF00C9A7),
  ];

  static const gradientIncome = [Color(0xFF00C9A7), Color(0xFF3DDC97)];
  static const gradientExpense = [Color(0xFFFF6B7A), Color(0xFFFFB547)];
}
