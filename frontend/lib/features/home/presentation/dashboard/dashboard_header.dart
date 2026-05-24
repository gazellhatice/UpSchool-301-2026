import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_screen_header.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user.displayName?.split(' ').first ?? 'Kullanıcı';

    return AppScreenHeader(
      sectionLabel: 'Özet',
      title: 'Merhaba, $name 👋',
      subtitle: 'Aylık bakiyeni, harcamalarını ve AI özetini tek ekranda gör',
      user: user,
      showSyncChip: true,
      onCoachTap: () => CoachChatScreen.show(context, user),
      bottom: const HeaderMonthSelector(),
    );
  }
}
