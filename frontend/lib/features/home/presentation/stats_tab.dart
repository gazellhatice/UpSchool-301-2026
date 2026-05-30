import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/budget_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/app_empty_state.dart';
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
              const SizedBox(height: 32),
              AppEmptyState(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Henüz gider verisi yok',
                message:
                    'Gider işlemi eklediğinde pasta grafik, kategori analizi ve aylık trend burada görünecek.',
                accentColor: AppColors.primary,
                actionLabel: 'Gider ekle',
                onAction: () => TransactionFormSheet.show(context, userId),
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
