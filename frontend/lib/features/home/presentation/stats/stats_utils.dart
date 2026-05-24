import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';

class CategoryComparison {
  const CategoryComparison({
    required this.stat,
    required this.previousAmount,
    required this.delta,
    required this.deltaPercent,
    required this.hasPrevious,
  });

  final CategoryStat stat;
  final double previousAmount;
  final double delta;
  final double? deltaPercent;
  final bool hasPrevious;

  bool get increased => delta > 0;
}

List<CategoryComparison> compareCategoryStats({
  required List<CategoryStat> current,
  required List<CategoryStat>? previous,
}) {
  final previousMap = {
    for (final stat in previous ?? const <CategoryStat>[])
      stat.category.id: stat.amount,
  };

  return current
      .map((stat) {
        final prev = previousMap[stat.category.id] ?? 0;
        final hasPrevious = previous != null &&
            previous.any((p) =>
                p.category.id == stat.category.id && p.amount > 0);
        return CategoryComparison(
          stat: stat,
          previousAmount: prev,
          delta: stat.amount - prev,
          deltaPercent: prev > 0 ? ((stat.amount - prev) / prev) * 100 : null,
          hasPrevious: hasPrevious || prev > 0,
        );
      })
      .toList();
}

double averageDailyExpense({
  required DateTime month,
  required double expense,
}) {
  if (expense <= 0) return 0;

  final now = DateTime.now();
  final isCurrentMonth =
      month.year == now.year && month.month == now.month;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final divisor = isCurrentMonth ? now.day.clamp(1, daysInMonth) : daysInMonth;
  return expense / divisor;
}

int expenseTransactionCount(MonthSummary summary) =>
    summary.transactions.where((tx) => !tx.isIncome).length;

List<String> buildStatsInsights({
  required MonthSummary summary,
  required List<CategoryStat> stats,
  required List<CategoryComparison> comparisons,
  required MonthComparison monthComparison,
  required double? budget,
}) {
  if (stats.isEmpty) return const [];

  final insights = <String>[];
  final top = stats.first;

  insights.add(
    'En büyük harcama kalemin ${top.category.name} '
    '(${top.percent.round()}%, ${formatCurrency(top.amount)}).',
  );

  if (monthComparison.hasPreviousData) {
    if (monthComparison.expenseDelta > 0) {
      insights.add(
        'Geçen aya göre ${formatCurrency(monthComparison.expenseDelta)} '
        'daha fazla harcadın.',
      );
    } else if (monthComparison.expenseDelta < 0) {
      insights.add(
        'Geçen aya göre ${formatCurrency(monthComparison.expenseDelta.abs())} '
        'daha az harcadın — iyi gidiyorsun.',
      );
    } else {
      insights.add('Geçen ay ile harcaman aynı seviyede.');
    }
  }

  final biggestIncrease = comparisons
      .where((c) => c.hasPrevious && c.delta > 0 && c.deltaPercent != null)
      .toList()
    ..sort((a, b) => b.delta.compareTo(a.delta));
  if (biggestIncrease.isNotEmpty) {
    final item = biggestIncrease.first;
    insights.add(
      '${item.stat.category.name} harcaması geçen aya göre '
      '${item.deltaPercent!.round()}% arttı.',
    );
  }

  if (budget != null && budget > 0 && summary.expense > budget) {
    insights.add(
      'Aylık bütçeni ${formatCurrency(summary.expense - budget)} aştın.',
    );
  } else if (budget != null && budget > 0) {
    insights.add(
      'Bütçenin ${formatCurrency(budget - summary.expense)} kadarı kaldı.',
    );
  }

  return insights.take(4).toList();
}

List<TransactionItem> transactionsForCategory({
  required MonthSummary summary,
  required String categoryId,
}) {
  return summary.transactions
      .where((tx) => !tx.isIncome && tx.categoryId == categoryId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
