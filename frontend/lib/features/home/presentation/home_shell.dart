import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/settings_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    final showAddFab = index == 0 || index == 2;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: index,
            children: [
              DashboardTab(user: user),
              StatsTab(userId: user.uid, user: user),
              CalendarTab(userId: user.uid, user: user),
              SettingsTab(
                user: user,
                authService: authService,
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'coach_fab',
              onPressed: () => CoachChatScreen.show(context, user),
              backgroundColor: const Color(0xFF6C63FF),
              elevation: 4,
              tooltip: 'Finans Koçu',
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
              ),
            ),
            if (showAddFab) ...[
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'add_transaction_fab',
                onPressed: () =>
                    TransactionFormSheet.show(context, user.uid),
                icon: const Icon(Icons.add_rounded),
                label: const Text('İşlem ekle'),
                backgroundColor: AppColors.primary,
              ),
            ],
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: NavigationBar(
            selectedIndex: index,
            height: 68,
            onDestinationSelected: (value) =>
                ref.read(homeTabIndexProvider.notifier).state = value,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: 'Özet',
              ),
              NavigationDestination(
                icon: Icon(Icons.donut_large_outlined),
                selectedIcon: Icon(Icons.donut_large_rounded),
                label: 'Analiz',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Takvim',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
