import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';

typedef ProfileAvatarOption = ({String emoji, Color color});

abstract final class ProfileAvatars {
  static const options = <ProfileAvatarOption>[
    (emoji: '😊', color: Color(0xFF6C63FF)),
    (emoji: '🦊', color: Color(0xFFFF6B6B)),
    (emoji: '🐬', color: Color(0xFF48CAE4)),
    (emoji: '🌿', color: Color(0xFF52B788)),
    (emoji: '🔥', color: Color(0xFFFF9F1C)),
    (emoji: '⚡', color: Color(0xFFFFD60A)),
    (emoji: '🎯', color: Color(0xFFE63946)),
    (emoji: '🦋', color: Color(0xFFB5179E)),
    (emoji: '🐉', color: Color(0xFF2D6A4F)),
    (emoji: '🚀', color: Color(0xFF023E8A)),
    (emoji: '🌙', color: Color(0xFF7B2D8B)),
    (emoji: '💎', color: Color(0xFF0096C7)),
  ];

  static int? indexFromPhotoUrl(String? photoUrl) {
    if (photoUrl == null || !photoUrl.startsWith('avatar:')) return null;
    final idx = int.tryParse(photoUrl.replaceFirst('avatar:', ''));
    if (idx == null || idx < 0 || idx >= options.length) return null;
    return idx;
  }

  static Widget build(
    User user, {
    double radius = 32,
    double? fontSize,
  }) {
    final idx = indexFromPhotoUrl(user.photoURL);
    if (idx != null) {
      final av = options[idx];
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: av.color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: av.color, width: 2),
        ),
        child: Center(
          child: Text(av.emoji, style: TextStyle(fontSize: fontSize ?? radius * 0.85)),
        ),
      );
    }

    final photoUrl = user.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    final initial = (user.displayName ?? user.email ?? 'K')[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: fontSize ?? radius * 0.9,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

String authProviderLabel(User user) {
  for (final info in user.providerData) {
    if (info.providerId == 'google.com') return 'Google hesabı';
    if (info.providerId == 'password') return 'E-posta hesabı';
  }
  return 'Firebase hesabı';
}

IconData authProviderIcon(User user) {
  for (final info in user.providerData) {
    if (info.providerId == 'google.com') return Icons.g_mobiledata_rounded;
    if (info.providerId == 'password') return Icons.mail_outline_rounded;
  }
  return Icons.account_circle_outlined;
}

String memberSinceLabel(User user) {
  final created = user.metadata.creationTime;
  if (created == null) return 'Yeni üye';
  return 'Üyelik: ${created.day}.${created.month}.${created.year}';
}
