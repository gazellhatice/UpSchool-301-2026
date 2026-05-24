import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';

class StatsDonutChart extends StatefulWidget {
  const StatsDonutChart({
    super.key,
    required this.stats,
    required this.totalExpense,
  });

  final List<CategoryStat> stats;
  final double totalExpense;

  @override
  State<StatsDonutChart> createState() => _StatsDonutChartState();
}

class _StatsDonutChartState extends State<StatsDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final touched = _touchedIndex;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori dağılımı',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 62,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response?.touchedSection == null) {
                            _touchedIndex = null;
                            return;
                          }
                          _touchedIndex =
                              response!.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: [
                      for (var i = 0; i < widget.stats.length; i++)
                        PieChartSectionData(
                          value: widget.stats[i].amount,
                          color: widget.stats[i].category.color,
                          radius: touched == i ? 48 : 40,
                          title: widget.stats[i].percent >= 8
                              ? '${widget.stats[i].percent.round()}%'
                              : '',
                          titleStyle: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      touched != null
                          ? widget.stats[touched].category.name
                          : 'Toplam',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      touched != null
                          ? formatCurrency(widget.stats[touched].amount)
                          : formatCurrency(widget.totalExpense),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
