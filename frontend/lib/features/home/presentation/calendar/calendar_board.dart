import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar/calendar_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarBoard extends StatelessWidget {
  const CalendarBoard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.dayFinanceMap,
    required this.maxExpense,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, DayFinance> dayFinanceMap;
  final double maxExpense;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focused) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        locale: 'tr_TR',
        availableGestures: AvailableGestures.all,
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          final finance = dayFinanceMap[key];
          return finance != null && finance.hasActivity ? [finance] : [];
        },
        calendarStyle: CalendarStyle(
          cellMargin: const EdgeInsets.all(6),
          markersMaxCount: 1,
          markerSize: 0,
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
          ),
          selectedDecoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.gradientCard),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: palette.textSecondary),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(Icons.chevron_left_rounded, color: palette.textPrimary),
          rightChevronIcon: Icon(Icons.chevron_right_rounded, color: palette.textPrimary),
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedMonth) =>
              _buildDayCell(context, day, isSelected: false, isToday: false),
          todayBuilder: (context, day, focusedMonth) =>
              _buildDayCell(context, day, isSelected: false, isToday: true),
          selectedBuilder: (context, day, focusedMonth) =>
              _buildDayCell(context, day, isSelected: true, isToday: isSameDay(day, DateTime.now())),
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            final finance = events.first as DayFinance;
            if (finance.expense <= 0 && finance.income <= 0) {
              return null;
            }

            final label = finance.expense > 0
                ? formatCompactCurrency(finance.expense)
                : '+${formatCompactCurrency(finance.income)}';
            final color = finance.expense > 0
                ? AppColors.danger
                : AppColors.accent;

            return Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            );
          },
        ),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
      ),
    );
  }

  Widget? _buildDayCell(
    BuildContext context,
    DateTime day, {
    required bool isSelected,
    required bool isToday,
  }) {
    final key = DateTime(day.year, day.month, day.day);
    final finance = dayFinanceMap[key];
    final intensity = finance != null && maxExpense > 0 && finance.expense > 0
        ? (finance.expense / maxExpense).clamp(0.08, 0.35)
        : 0.0;

    if (isSelected || isToday) {
      return null;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: intensity > 0
            ? AppColors.danger.withValues(alpha: intensity)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class CalendarDaySummary extends StatelessWidget {
  const CalendarDaySummary({
    super.key,
    required this.selectedDay,
    required this.summary,
    required this.onAddTap,
  });

  final DateTime selectedDay;
  final DayFinance summary;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final dateLabel = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(selectedDay);
    final relative = dayRelativeLabel(selectedDay);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (relative.isNotEmpty)
                      Text(
                        relative,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    Text(
                      dateLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricChip(
                label: 'Gelir',
                value: formatCurrency(summary.income),
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: 'Gider',
                value: formatCurrency(summary.expense),
                color: AppColors.danger,
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: 'Net',
                value: formatCurrency(summary.net),
                color: summary.net >= 0 ? AppColors.primary : AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
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

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
