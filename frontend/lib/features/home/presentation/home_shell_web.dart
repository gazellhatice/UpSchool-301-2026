import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/gradient_background.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/settings_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats_tab.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class HomeShellWeb extends ConsumerWidget {
  const HomeShellWeb({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  static const _destinations = [
    _WebNavItem(
      label: 'Özet',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    _WebNavItem(
      label: 'Analiz',
      icon: Icons.donut_large_outlined,
      selectedIcon: Icons.donut_large_rounded,
    ),
    _WebNavItem(
      label: 'Takvim',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    _WebNavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    final palette = context.palette;
    final showAddAction = index == 0 || index == 2;
    final displayName = user.displayName?.trim();
    final subtitle = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : user.email ?? '';

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: ResponsiveBreakpoints.sidebarWidth,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 12, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const AppLogo(size: 40, borderRadius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppConstants.appName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      ...List.generate(_destinations.length, (i) {
                        final item = _destinations[i];
                        final selected = index == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _SidebarNavButton(
                            item: item,
                            selected: selected,
                            onTap: () => ref
                                .read(homeTabIndexProvider.notifier)
                                .state = i,
                          ),
                        );
                      }),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => CoachChatScreen.show(context, user),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Finans Koçu'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      if (showAddAction) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () =>
                              TransactionFormSheet.show(context, user.uid),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('İşlem ekle'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.glassSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.glassBorder),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: palette.surfaceLight,
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: user.photoURL == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 20,
                                      color: palette.textSecondary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: palette.textSecondary,
                                      height: 1.3,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 32, 0),
                      child: Text(
                        _destinations[index].label,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ResponsiveBreakpoints.contentMaxWidth,
                          ),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebNavItem {
  const _WebNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _SidebarNavButton extends StatelessWidget {
  const _SidebarNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _WebNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.14)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: selected ? AppColors.primary : palette.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? palette.textPrimary
                          : palette.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
