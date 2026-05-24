import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/budget_edit_sheet.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';

class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({
    super.key,
    required this.summary,
    required this.comparison,
    required this.budget,
    required this.month,
    required this.userId,
  });

  final MonthSummary summary;
  final MonthComparison comparison;
  final double? budget;
  final DateTime month;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usage = progressValue(
      expense: summary.expense,
      budget: budget,
      income: summary.income,
    );
    final pace = spendingPaceMessage(
      month: month,
      expense: summary.expense,
      budget: budget,
      income: summary.income,
    );
    final barColor = _barColor(usage, budget != null);

    return GestureDetector(
      onTap: () => BudgetEditSheet.show(
        context,
        userId: userId,
        currentBudget: budget,
        monthExpense: summary.expense,
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientCard,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Net bakiye',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_calendar_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 4),
                Text(
                  budget != null ? 'Bütçe ayarlı' : 'Bütçe ekle',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(summary.balance),
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            if (comparison.hasPreviousData) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    comparison.balanceImproved
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Geçen aya göre ${formatDeltaCurrency(comparison.balanceDelta)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: usage,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                color: barColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progressLabel(
                expense: summary.expense,
                budget: budget,
                income: summary.income,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            if (pace.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                pace,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _barColor(double usage, bool hasBudget) {
    if (!hasBudget) return Colors.white;
    if (usage >= 1) return const Color(0xFFFF6B7A);
    if (usage >= 0.8) return const Color(0xFFFFB547);
    return Colors.white;
  }
}

class DashboardMiniStatCard extends StatelessWidget {
  const DashboardMiniStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.gradient,
    required this.icon,
    this.deltaLabel,
  });

  final String label;
  final String value;
  final List<Color> gradient;
  final IconData icon;
  final String? deltaLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 12),
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
          if (deltaLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              deltaLabel!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DashboardInsightStrip extends StatelessWidget {
  const DashboardInsightStrip({
    super.key,
    required this.todayExpense,
    required this.todayCount,
    required this.savingsRatePercent,
  });

  final double todayExpense;
  final int todayCount;
  final double? savingsRatePercent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InsightTile(
            icon: Icons.today_rounded,
            label: 'Bugün',
            value: formatCurrency(todayExpense),
            subtitle: todayCount == 0
                ? 'Henüz işlem yok'
                : '$todayCount işlem',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InsightTile(
            icon: Icons.savings_rounded,
            label: 'Tasarruf',
            value: savingsRatePercent == null
                ? '—'
                : '%${savingsRatePercent!.round()}',
            subtitle: savingsRatePercent == null
                ? 'Gelir girilince hesaplanır'
                : savingsRatePercent! >= 0
                    ? 'Gelirinden kalan pay'
                    : 'Gelirini aştın',
            color: savingsRatePercent != null && savingsRatePercent! >= 0
                ? AppColors.accent
                : AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

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
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
