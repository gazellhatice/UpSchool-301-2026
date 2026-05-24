import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_category_detail_sheet.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_utils.dart';

class StatsInsightsCard extends StatelessWidget {
  const StatsInsightsCard({super.key, required this.insights});

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (insights.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: AppColors.accentWarm,
              ),
              const SizedBox(width: 8),
              Text(
                'Öne çıkanlar',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 7, right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentWarm.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
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

class StatsCategoryBreakdown extends StatelessWidget {
  const StatsCategoryBreakdown({
    super.key,
    required this.comparisons,
    required this.userId,
    required this.month,
  });

  final List<CategoryComparison> comparisons;
  final String userId;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori detayı',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Detay için kategoriye dokun',
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        for (final item in comparisons)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CategoryRow(
              comparison: item,
              onTap: () => StatsCategoryDetailSheet.show(
                context,
                userId: userId,
                month: month,
                category: item.stat.category,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.comparison,
    required this.onTap,
  });

  final CategoryComparison comparison;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final stat = comparison.stat;
    final color = stat.category.color;

    return Material(
      color: palette.surfaceLight.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(stat.category.icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.category.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${stat.percent.round()}% · ${formatCurrency(stat.amount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (comparison.hasPrevious && comparison.delta != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (comparison.increased
                                ? AppColors.danger
                                : AppColors.accent)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        comparison.deltaPercent != null
                            ? '${comparison.increased ? '+' : ''}${comparison.deltaPercent!.round()}%'
                            : formatDeltaCurrency(comparison.delta),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: comparison.increased
                              ? AppColors.danger
                              : AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: palette.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (stat.percent / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: palette.border.withValues(alpha: 0.35),
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
