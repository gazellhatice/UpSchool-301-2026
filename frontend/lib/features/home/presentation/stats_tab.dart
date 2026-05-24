import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/budget_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_category_section.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_donut_chart.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_header.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_monthly_trend_chart.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_summary_cards.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key, required this.userId, required this.user});

  final String userId;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final month = ref.watch(selectedMonthProvider);
    final budget = ref.watch(monthlyBudgetProvider(userId));
    final statsAsync = ref.watch(
      expenseStatsProvider((userId: userId, month: month)),
    );
    final summaryAsync = ref.watch(
      monthSummaryProvider((userId: userId, month: month)),
    );
    final previousStatsAsync = ref.watch(
      expenseStatsProvider((
        userId: userId,
        month: DateTime(month.year, month.month - 1),
      )),
    );
    final previousSummaryAsync = ref.watch(
      previousMonthSummaryProvider((userId: userId, month: month)),
    );
    final monthlyTrendAsync = ref.watch(
      monthlyExpenseTrendProvider((userId: userId, month: month)),
    );

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Analiz yüklenemedi: $e')),
      data: (stats) {
        if (stats.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              StatsHeader(user: user),
              const SizedBox(height: 48),
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz gider verisi yok',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gider işlemi eklediğinde pasta grafik, kategori analizi ve '
                'aylık trend burada görünecek.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: FilledButton.icon(
                  onPressed: () {
                    ref.read(homeTabIndexProvider.notifier).state = 0;
                    TransactionFormSheet.show(context, userId);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('İlk gideri ekle'),
                ),
              ),
            ],
          );
        }

        final summary = summaryAsync.valueOrNull;
        final previousSummary = previousSummaryAsync.valueOrNull;
        final monthComparison = summary == null
            ? const MonthComparison(
                balanceDelta: 0,
                expenseDelta: 0,
                hasPreviousData: false,
              )
            : compareMonths(current: summary, previous: previousSummary);
        final comparisons = compareCategoryStats(
          current: stats,
          previous: previousStatsAsync.valueOrNull,
        );
        final insights = summary == null
            ? const <String>[]
            : buildStatsInsights(
                summary: summary,
                stats: stats,
                comparisons: comparisons,
                monthComparison: monthComparison,
                budget: budget,
              );
        final monthlyTrend = monthlyTrendAsync.valueOrNull ?? const [];
        final totalExpense = stats.fold<double>(0, (s, item) => s + item.amount);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            StatsHeader(user: user),
            const SizedBox(height: 20),
            StatsSummaryStrip(
              totalExpense: totalExpense,
              averageDaily: averageDailyExpense(month: month, expense: totalExpense),
              categoryCount: stats.length,
              transactionCount: summary == null
                  ? 0
                  : expenseTransactionCount(summary),
              monthComparison: monthComparison,
            ),
            if (summary != null) ...[
              const SizedBox(height: 16),
              StatsIncomeExpenseCard(
                income: summary.income,
                expense: summary.expense,
              ),
            ],
            const SizedBox(height: 16),
            StatsInsightsCard(insights: insights),
            const SizedBox(height: 16),
            StatsDonutChart(
              stats: stats,
              totalExpense: totalExpense,
            ),
            if (monthlyTrend.isNotEmpty) ...[
              const SizedBox(height: 16),
              StatsMonthlyTrendChart(days: monthlyTrend, month: month),
            ],
            const SizedBox(height: 24),
            StatsCategoryBreakdown(
              comparisons: comparisons,
              userId: userId,
              month: month,
            ),
          ],
        );
      },
    );
  }
}
