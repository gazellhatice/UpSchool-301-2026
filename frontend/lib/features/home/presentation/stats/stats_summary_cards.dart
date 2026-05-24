import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';

class StatsSummaryStrip extends StatelessWidget {
  const StatsSummaryStrip({
    super.key,
    required this.totalExpense,
    required this.averageDaily,
    required this.categoryCount,
    required this.transactionCount,
    required this.monthComparison,
  });

  final double totalExpense;
  final double averageDaily;
  final int categoryCount;
  final int transactionCount;
  final MonthComparison monthComparison;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Toplam gider',
                value: formatCurrency(totalExpense),
                icon: Icons.payments_rounded,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiTile(
                label: 'Günlük ort.',
                value: formatCurrency(averageDaily),
                icon: Icons.calendar_view_day_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Kategori',
                value: '$categoryCount',
                icon: Icons.category_rounded,
                color: AppColors.primaryGlow,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiTile(
                label: 'İşlem',
                value: '$transactionCount',
                icon: Icons.receipt_long_rounded,
                color: AppColors.accentWarm,
                subtitle: monthComparison.hasPreviousData
                    ? 'Geçen aya göre ${formatDeltaCurrency(monthComparison.expenseDelta)}'
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatsIncomeExpenseCard extends StatelessWidget {
  const StatsIncomeExpenseCard({
    super.key,
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = income + expense;
    final incomeFlex = total <= 0 ? 1 : (income / total * 100).round().clamp(1, 99);
    final expenseFlex = total <= 0 ? 1 : 100 - incomeFlex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gelir vs gider',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: incomeFlex,
                    child: Container(color: AppColors.accent),
                  ),
                  Expanded(
                    flex: expenseFlex,
                    child: Container(color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: AppColors.accent, label: 'Gelir', value: income),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.danger, label: 'Gider', value: expense),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                Text(
                  formatCurrency(value),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
