import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_screen_header.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';

class StatsHeader extends ConsumerWidget {
  const StatsHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ResponsiveBreakpoints.isWideLayout(context)) {
      return const SizedBox.shrink();
    }

    return AppScreenHeader(
      sectionLabel: 'Analiz',
      title: 'Harcama analizi',
      subtitle: 'Kategori dağılımı, trendler ve geçen ay karşılaştırması',
      user: user,
      onCoachTap: () => CoachChatScreen.open(context, user),
      bottom: const HeaderMonthSelector(),
    );
  }
}
