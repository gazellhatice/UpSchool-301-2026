import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';

class StatsMonthlyTrendChart extends StatelessWidget {
  const StatsMonthlyTrendChart({
    super.key,
    required this.days,
    required this.month,
  });

  final List<DailyExpenseTotal> days;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    if (days.isEmpty) return const SizedBox.shrink();

    final maxY = days.fold<double>(0, (m, d) => d.amount > m ? d.amount : m);
    final chartMax = maxY <= 0 ? 100.0 : maxY * 1.25;
    final activeDays = days.where((d) => d.amount > 0).length;
    final monthLabel = DateFormat('MMMM', 'tr_TR').format(month);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthLabel günlük harcama',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$activeDays günde harcama yapıldı',
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMax / 3,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: palette.border.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: days.length > 20 ? 5 : 2,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        if (days.length > 20 && index % 5 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${days[index].day.day}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: palette.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: days[i].amount,
                          width: days.length > 20 ? 6 : 10,
                          borderRadius: BorderRadius.circular(4),
                          color: days[i].amount > 0
                              ? AppColors.danger.withValues(alpha: 0.85)
                              : palette.border.withValues(alpha: 0.35),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ay toplamı: ${formatCurrency(days.fold(0.0, (s, d) => s + d.amount))}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
