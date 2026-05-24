import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/budget_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/coach_insight_card.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_header.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_hero_card.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_quick_add_row.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_top_category_card.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_transaction_section.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_weekly_chart.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final budget = ref.watch(monthlyBudgetProvider(user.uid));
    final summaryAsync = ref.watch(
      monthSummaryProvider((userId: user.uid, month: month)),
    );
    final previousAsync = ref.watch(
      previousMonthSummaryProvider((userId: user.uid, month: month)),
    );
    final todayAsync = ref.watch(todaySummaryProvider(user.uid));
    final statsAsync = ref.watch(
      expenseStatsProvider((userId: user.uid, month: month)),
    );
    final weeklyAsync = ref.watch(weeklyExpenseTrendProvider(user.uid));
    final quickCategories = ref.watch(quickExpenseCategoriesProvider(user.uid));

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Veri yüklenemedi: $e')),
      data: (summary) {
        final previous = previousAsync.valueOrNull;
        final comparison = compareMonths(current: summary, previous: previous);
        final today = todayAsync.valueOrNull;
        final stats = statsAsync.valueOrNull ?? const [];
        final weekly = weeklyAsync.valueOrNull ?? const [];
        final rate = savingsRate(summary);

        String? expenseDeltaLabel;
        if (comparison.hasPreviousData && previous != null) {
          expenseDeltaLabel =
              'Geçen ay: ${formatCurrency(previous.expense)}';
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            DashboardHeader(user: user),
            const SizedBox(height: 20),
            DashboardHeroCard(
              summary: summary,
              comparison: comparison,
              budget: budget,
              month: month,
              userId: user.uid,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DashboardMiniStatCard(
                    label: 'Gelir',
                    value: formatCurrency(summary.income),
                    gradient: AppColors.gradientIncome,
                    icon: Icons.trending_up_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardMiniStatCard(
                    label: 'Gider',
                    value: formatCurrency(summary.expense),
                    gradient: AppColors.gradientExpense,
                    icon: Icons.trending_down_rounded,
                    deltaLabel: expenseDeltaLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DashboardInsightStrip(
              todayExpense: today?.expense ?? 0,
              todayCount: today?.transactionCount ?? 0,
              savingsRatePercent:
                  rate == null ? null : (rate * 100).clamp(-999, 999),
            ),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              DashboardTopCategoryCard(topStat: stats.first),
            ],
            if (weekly.isNotEmpty) ...[
              const SizedBox(height: 16),
              DashboardWeeklyChart(days: weekly),
            ],
            const SizedBox(height: 16),
            CoachInsightCard(user: user),
            const SizedBox(height: 20),
            DashboardQuickAddRow(
              userId: user.uid,
              categories: quickCategories,
            ),
            const SizedBox(height: 24),
            DashboardTransactionSection(
              userId: user.uid,
              transactions: summary.transactions,
            ),
          ],
        );
      },
    );
  }
}
