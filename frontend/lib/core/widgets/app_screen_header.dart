import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/constants/app_constants.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/sync_status_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_logo.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/profile/profile_avatars.dart';

/// Tüm ana sekmelerde ortak üst başlık çerçevesi.
class AppScreenHeader extends ConsumerWidget {
  const AppScreenHeader({
    super.key,
    required this.sectionLabel,
    required this.title,
    required this.subtitle,
    this.user,
    this.showProfileAvatar = true,
    this.showSyncChip = false,
    this.showCoachButton = true,
    this.hideBrandLogo = false,
    this.shellLayout = false,
    this.onCoachTap,
    this.bottom,
  });

  final String sectionLabel;
  final String title;
  final String subtitle;
  final User? user;
  final bool showProfileAvatar;
  final bool showSyncChip;
  final bool showCoachButton;
  final bool hideBrandLogo;
  final bool shellLayout;
  final VoidCallback? onCoachTap;
  final Widget? bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final lastSync = ref.watch(lastSyncAtProvider);

    final titleStyle = shellLayout
        ? theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.12,
          )
        : theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.15,
          );

    return Container(
      padding: shellLayout
          ? const EdgeInsets.fromLTRB(0, 4, 0, 14)
          : const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: shellLayout
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: palette.border.withValues(alpha: 0.85),
                ),
              ),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.surfaceLight.withValues(alpha: 0.92),
                  palette.surface.withValues(alpha: 0.62),
                ],
              ),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hideBrandLogo) ...[
                AppBrandButton(
                  tooltip: AppConstants.appName,
                  onTap: () =>
                      ref.read(homeTabIndexProvider.notifier).state = 0,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (shellLayout && hideBrandLogo)
                      _ShellBreadcrumb(sectionLabel: sectionLabel),
                    if (shellLayout && hideBrandLogo)
                      const SizedBox(height: 10)
                    else
                      _SectionEyebrow(label: sectionLabel),
                    if (!shellLayout || !hideBrandLogo)
                      const SizedBox(height: 8),
                    Text(
                      title,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (showCoachButton)
                AppCoachButton(onTap: onCoachTap),
              if (showProfileAvatar && user != null) ...[
                const SizedBox(width: 8),
                _ProfileTap(
                  user: user!,
                  onTap: () =>
                      ref.read(homeTabIndexProvider.notifier).state = 3,
                ),
              ],
            ],
          ),
          if (showSyncChip || bottom != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (bottom != null) Expanded(child: bottom!),
                if (showSyncChip) ...[
                  if (bottom != null) const SizedBox(width: 8),
                  HeaderSyncChip(lastSync: lastSync),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AppBrandButton extends StatelessWidget {
  const AppBrandButton({
    super.key,
    required this.onTap,
    this.tooltip,
  });

  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? AppConstants.appName,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const AppLogo(
            size: 48,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}

class AppCoachButton extends StatelessWidget {
  const AppCoachButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Finans Koçu',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellBreadcrumb extends StatelessWidget {
  const _ShellBreadcrumb({required this.sectionLabel});

  final String sectionLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.home_work_outlined,
          size: 14,
          color: palette.textSecondary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            AppConstants.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: palette.textSecondary.withValues(alpha: 0.7),
          ),
        ),
        _SectionEyebrow(label: sectionLabel),
      ],
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _ProfileTap extends StatelessWidget {
  const _ProfileTap({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: ProfileAvatars.build(user, radius: 21, fontSize: 16),
      ),
    );
  }
}

class HeaderSyncChip extends StatelessWidget {
  const HeaderSyncChip({super.key, required this.lastSync});

  final DateTime? lastSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final label =
        lastSync == null ? 'Senkron yok' : _relativeTime(lastSync!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_done_rounded,
            size: 14,
            color: lastSync == null ? palette.textSecondary : Colors.greenAccent,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    return '${diff.inDays} gün';
  }
}

/// Özet / analiz sekmelerinde header altına yerleştirilen ay seçici.
class HeaderMonthSelector extends ConsumerWidget {
  const HeaderMonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final month = ref.watch(selectedMonthProvider);
    final label = DateFormat('MMMM yyyy', 'tr_TR').format(month);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final canGoForward = month.isBefore(currentMonth);

    void shift(int delta) {
      final next = DateTime(month.year, month.month + delta);
      if (next.isAfter(currentMonth)) return;
      ref.read(selectedMonthProvider.notifier).state = next;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Önceki ay',
            onPressed: () => shift(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sonraki ay',
            onPressed: canGoForward ? () => shift(1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
