import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DefaultCategorySeed {
  const DefaultCategorySeed({
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = true,
  });

  final String name;
  final IconData icon;
  final Color color;
  final bool isDefault;
}

abstract final class DefaultCategories {
  static const _uuid = Uuid();

  static const seeds = [
    DefaultCategorySeed(
      name: 'Maaş',
      icon: Icons.payments_rounded,
      color: Color(0xFF3DDC97),
    ),
    DefaultCategorySeed(
      name: 'Ek Gelir',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF7C4DFF),
    ),
    DefaultCategorySeed(
      name: 'Yemek',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFFB547),
    ),
    DefaultCategorySeed(
      name: 'Ulaşım',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF5B8CFF),
    ),
    DefaultCategorySeed(
      name: 'Kira',
      icon: Icons.home_rounded,
      color: Color(0xFF7C4DFF),
    ),
    DefaultCategorySeed(
      name: 'Eğlence',
      icon: Icons.movie_rounded,
      color: Color(0xFFFF6B7A),
    ),
    DefaultCategorySeed(
      name: 'Sağlık',
      icon: Icons.favorite_rounded,
      color: Color(0xFF3DDC97),
    ),
    DefaultCategorySeed(
      name: 'Diğer',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF9AA3B8),
    ),
  ];

  static String newId() => _uuid.v4();
}
