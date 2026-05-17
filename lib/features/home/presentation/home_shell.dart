import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/settings_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: _index,
            children: [
              DashboardTab(user: widget.user),
              StatsTab(userId: widget.user.uid),
              CalendarTab(userId: widget.user.uid),
              SettingsTab(
                user: widget.user,
                authService: widget.authService,
              ),
            ],
          ),
        ),
        floatingActionButton: _index == 0
            ? FloatingActionButton.extended(
                onPressed: () =>
                    TransactionFormSheet.show(context, widget.user.uid),
                icon: const Icon(Icons.add_rounded),
                label: const Text('İşlem ekle'),
                backgroundColor: AppColors.primary,
              )
            : null,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: NavigationBar(
            selectedIndex: _index,
            height: 68,
            onDestinationSelected: (value) => setState(() => _index = value),
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
