import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/navigation/app_navigation.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/budget_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/coach_panel_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/sync_status_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/presentation/sign_out_action.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/budget_edit_sheet.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/profile_avatars.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

/// Geniş web düzeninde sol navigasyon paneli.
class WebAppSidebar extends ConsumerWidget {
  const WebAppSidebar({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  static const _navItems = [
    _WebNavItem(
      tabIndex: 0,
      label: 'Özet',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    _WebNavItem(
      tabIndex: 1,
      label: 'Analiz',
      icon: Icons.donut_large_outlined,
      selectedIcon: Icons.donut_large_rounded,
    ),
    _WebNavItem(
      tabIndex: 2,
      label: 'Takvim',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    final coachOpen = ref.watch(coachPanelOpenProvider);
    final palette = context.palette;
    final displayName = user.displayName?.trim();
    final subtitle = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : user.email ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SidebarSectionLabel('Menü'),
          const SizedBox(height: 8),
          ..._navItems.map((item) {
            final selected = index == item.tabIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SidebarNavButton(
                item: item,
                selected: selected,
                onTap: () =>
                    navigateToAppTab(context, ref, item.tabIndex),
              ),
            );
          }),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              if (coachOpen) {
                ref.read(coachPanelOpenProvider.notifier).state = false;
              } else {
                CoachChatScreen.open(context, user);
              }
            },
            icon: Icon(
              coachOpen ? Icons.close_rounded : Icons.auto_awesome_rounded,
              size: 18,
            ),
            label: Text(coachOpen ? 'Koçu kapat' : 'Finans Koçu'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),
          const _SidebarSectionLabel('Bu ay'),
          const SizedBox(height: 8),
          _SidebarMonthSnapshot(userId: user.uid),
          const SizedBox(height: 18),
          const _SidebarSectionLabel('Hızlı erişim'),
          const SizedBox(height: 8),
          _SidebarQuickLink(
            icon: Icons.add_circle_outline_rounded,
            label: 'İşlem ekle',
            onTap: () => TransactionFormSheet.show(context, user.uid),
          ),
          const SizedBox(height: 4),
          _SidebarQuickLink(
            icon: Icons.savings_outlined,
            label: 'Bütçe hedefi',
            onTap: () => _openBudget(context, ref),
          ),
          const SizedBox(height: 4),
          _SidebarSyncLink(userId: user.uid),
          const SizedBox(height: 12),
          Text(
            'Kısayollar: N işlem · K koç · 1–3 sekme · 4 profil · Esc',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.textSecondary,
                  fontSize: 10,
                  height: 1.3,
                ),
          ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SidebarUserFooter(
            user: user,
            subtitle: subtitle,
            authService: authService,
            profileActive: index == 3,
          ),
        ],
      ),
    );
  }

  void _openBudget(BuildContext context, WidgetRef ref) {
    final month = ref.read(selectedMonthProvider);
    final budget = ref.read(monthlyBudgetProvider(user.uid));
    final summary = ref
        .read(
          monthSummaryProvider((userId: user.uid, month: month)),
        )
        .valueOrNull;

    BudgetEditSheet.show(
      context,
      userId: user.uid,
      currentBudget: budget,
      monthExpense: summary?.expense ?? 0,
    );
  }
}

class _WebNavItem {
  const _WebNavItem({
    required this.tabIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final int tabIndex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _SidebarSectionLabel extends StatelessWidget {
  const _SidebarSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: palette.textSecondary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            fontSize: 10,
          ),
    );
  }
}

class _SidebarMonthSnapshot extends ConsumerWidget {
  const _SidebarMonthSnapshot({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final month = ref.watch(selectedMonthProvider);
    final monthLabel = DateFormat('MMMM', 'tr_TR').format(month);
    final summaryAsync = ref.watch(
      monthSummaryProvider((userId: userId, month: month)),
    );

    return summaryAsync.when(
      loading: () => _SidebarGlassCard(
        child: SizedBox(
          height: 72,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => _SidebarGlassCard(
        child: Text(
          'Özet yüklenemedi',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
        ),
      ),
      data: (summary) {
        final net = summary.income - summary.expense;
        final netColor =
            net >= 0 ? const Color(0xFF3DDC97) : const Color(0xFFFF6B7A);

        return _SidebarGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                formatCurrency(net),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: netColor,
                      letterSpacing: -0.3,
                    ),
              ),
              Text(
                'Net bakiye',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: palette.textSecondary,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Gelir',
                      value: formatCurrency(summary.income),
                      color: const Color(0xFF3DDC97),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      label: 'Gider',
                      value: formatCurrency(summary.expense),
                      color: const Color(0xFFFF6B7A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _SidebarGlassCard extends StatelessWidget {
  const _SidebarGlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.glassBorder),
      ),
      child: child,
    );
  }
}

class _SidebarQuickLink extends StatelessWidget {
  const _SidebarQuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: palette.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: palette.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarSyncLink extends ConsumerStatefulWidget {
  const _SidebarSyncLink({required this.userId});

  final String userId;

  @override
  ConsumerState<_SidebarSyncLink> createState() => _SidebarSyncLinkState();
}

class _SidebarSyncLinkState extends ConsumerState<_SidebarSyncLink> {
  bool _syncing = false;

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final result =
          await ref.read(financeRepositoryProvider(widget.userId)).sync();
      if (!mounted) return;

      if (!result.wasOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İnternet bağlantısı yok — senkron atlandı'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (result.success) {
        await ref.read(lastSyncAtProvider.notifier).markSynced();
        ref.invalidate(monthSummaryProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senkronizasyon tamamlandı'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Senkron hatası: ${result.error}')),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    return '${diff.inDays} gün';
  }

  @override
  Widget build(BuildContext context) {
    final lastSync = ref.watch(lastSyncAtProvider);
    final syncLabel = lastSync == null ? '' : _relativeTime(lastSync);
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _syncing ? null : _sync,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _syncing
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    )
                  : Icon(
                      Icons.cloud_sync_rounded,
                      size: 18,
                      color: palette.textSecondary,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _syncing ? 'Senkronize ediliyor…' : 'Verileri senkronize et',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (syncLabel.isNotEmpty)
                Text(
                  syncLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarUserFooter extends ConsumerWidget {
  const _SidebarUserFooter({
    required this.user,
    required this.subtitle,
    required this.authService,
    required this.profileActive,
  });

  final User user;
  final String subtitle;
  final AuthService authService;
  final bool profileActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: profileActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : palette.glassSurface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => navigateToAppTab(context, ref, 3),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: profileActive
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : palette.glassBorder,
                ),
              ),
              child: Row(
                children: [
                  ProfileAvatars.build(
                    user,
                    radius: 18,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                        ),
                        Text(
                          'Profil & ayarlar',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: palette.textSecondary,
                                    fontSize: 10,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: profileActive
                        ? AppColors.primary
                        : palette.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => performSignOut(
            context: context,
            ref: ref,
            userId: user.uid,
            authService: authService,
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Çıkış yap'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: BorderSide(
              color: AppColors.danger.withValues(alpha: 0.4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
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
