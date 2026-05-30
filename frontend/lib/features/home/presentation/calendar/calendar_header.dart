import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/responsive_breakpoints.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_screen_header.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_chat_screen.dart';

class CalendarHeader extends ConsumerWidget {
  const CalendarHeader({
    super.key,
    required this.user,
    required this.focusedMonth,
    required this.onTodayTap,
  });

  final User user;
  final DateTime focusedMonth;
  final VoidCallback onTodayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final monthLabel = DateFormat('MMMM yyyy', 'tr_TR').format(focusedMonth);
    final now = DateTime.now();
    final isCurrentMonth =
        focusedMonth.year == now.year && focusedMonth.month == now.month;

    final monthBar = Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              monthLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        if (!isCurrentMonth) ...[
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: onTodayTap,
            icon: const Icon(Icons.today_rounded, size: 18),
            label: const Text('Bugün'),
          ),
        ],
      ],
    );

    if (ResponsiveBreakpoints.isWideLayout(context)) {
      return monthBar;
    }

    return AppScreenHeader(
      sectionLabel: 'Takvim',
      title: 'Günlük harcama takvimi',
      subtitle: 'İşlem günlerini gör, seçili günün detayına in',
      user: user,
      onCoachTap: () => CoachChatScreen.open(context, user),
      bottom: monthBar,
    );
  }
}

class CalendarMonthOverview extends StatelessWidget {
  const CalendarMonthOverview({
    super.key,
    required this.summary,
    required this.activeDays,
  });

  final MonthSummary summary;
  final int activeDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OverviewTile(
            label: 'Ay geliri',
            value: _format(summary.income),
            color: const Color(0xFF3DDC97),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OverviewTile(
            label: 'Ay gideri',
            value: _format(summary.expense),
            color: const Color(0xFFFF6B7A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OverviewTile(
            label: 'Aktif gün',
            value: '$activeDays',
            color: const Color(0xFF5B8CFF),
          ),
        ),
      ],
    );
  }

  String _format(double value) {
    if (value >= 1000) {
      return '₺${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}K';
    }
    return '₺${value.round()}';
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
