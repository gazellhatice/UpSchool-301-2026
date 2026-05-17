import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isDefault,
    required this.isIncome,
    required this.synced,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final bool isDefault;
  final bool isIncome;
  final bool synced;
  final DateTime updatedAt;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}
