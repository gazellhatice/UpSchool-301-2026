import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';

class MonthComparison {
  const MonthComparison({
    required this.balanceDelta,
    required this.expenseDelta,
    required this.hasPreviousData,
  });

  final double balanceDelta;
  final double expenseDelta;
  final bool hasPreviousData;

  bool get balanceImproved => balanceDelta >= 0;
}

MonthComparison compareMonths({
  required MonthSummary current,
  required MonthSummary? previous,
}) {
  if (previous == null ||
      (previous.income == 0 &&
          previous.expense == 0 &&
          previous.transactions.isEmpty)) {
    return const MonthComparison(
      balanceDelta: 0,
      expenseDelta: 0,
      hasPreviousData: false,
    );
  }

  return MonthComparison(
    balanceDelta: current.balance - previous.balance,
    expenseDelta: current.expense - previous.expense,
    hasPreviousData: true,
  );
}

String formatDeltaCurrency(double delta) {
  final prefix = delta >= 0 ? '+' : '';
  return '$prefix${formatCurrency(delta)}';
}

String formatPercentDelta(double current, double previous) {
  if (previous == 0) return '';
  final pct = ((current - previous) / previous.abs()) * 100;
  final prefix = pct >= 0 ? '+' : '';
  return '$prefix${pct.round()}%';
}

double? savingsRate(MonthSummary summary) {
  if (summary.income <= 0) return null;
  return ((summary.income - summary.expense) / summary.income).clamp(-1.0, 1.0);
}

String spendingPaceMessage({
  required DateTime month,
  required double expense,
  required double? budget,
  required double income,
}) {
  final now = DateTime.now();
  final isCurrentMonth =
      month.year == now.year && month.month == now.month;
  if (!isCurrentMonth) return '';

  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final daysElapsed = now.day;
  final timeRatio = daysElapsed / daysInMonth;

  double spendRatio;
  if (budget != null && budget > 0) {
    spendRatio = (expense / budget).clamp(0.0, 2.0);
  } else if (income > 0) {
    spendRatio = (expense / income).clamp(0.0, 2.0);
  } else {
    return 'Bu ay henüz gelir kaydı yok';
  }

  if (spendRatio > timeRatio + 0.08) {
    return 'Harcama tempon biraz hızlı — ayın ${(timeRatio * 100).round()}%\'inde '
        'harcamanın ${(spendRatio * 100).round()}%\'ine ulaştın';
  }
  if (spendRatio < timeRatio - 0.08) {
    return 'Harika gidiyorsun — harcama tempon planın altında';
  }
  return 'Harcama tempon ayın ilerleyişiyle uyumlu';
}

String progressLabel({
  required double expense,
  required double? budget,
  required double income,
}) {
  if (budget != null && budget > 0) {
    final pct = ((expense / budget) * 100).clamp(0, 999).round();
    return 'Aylık bütçenin %$pct\'i kullanıldı';
  }
  if (income > 0) {
    final pct = ((expense / income) * 100).clamp(0, 999).round();
    return 'Gelirinin %$pct\'i harcandı';
  }
  return 'Bu ay henüz gelir kaydı yok';
}

double progressValue({
  required double expense,
  required double? budget,
  required double income,
}) {
  if (budget != null && budget > 0) {
    return (expense / budget).clamp(0.0, 1.0);
  }
  if (income > 0) {
    return (expense / income).clamp(0.0, 1.0);
  }
  return 0;
}

String transactionGroupLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;

  if (diff == 0) return 'Bugün';
  if (diff == 1) return 'Dün';
  return DateFormat('d MMMM', 'tr_TR').format(date);
}

Map<String, List<T>> groupTransactionsByDay<T>(
  List<T> items,
  DateTime Function(T item) dateSelector,
) {
  final groups = <String, List<T>>{};
  final order = <String>[];

  for (final item in items) {
    final label = transactionGroupLabel(dateSelector(item));
    if (!groups.containsKey(label)) {
      groups[label] = [];
      order.add(label);
    }
    groups[label]!.add(item);
  }

  return {for (final key in order) key: groups[key]!};
}

List<String> extractInsightBullets(String text) {
  final lines = text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  final bullets = <String>[];
  for (final line in lines) {
    final cleaned = line
        .replaceFirst(RegExp(r'^[-•*]\s*'), '')
        .replaceFirst(RegExp(r'^\d+[.)]\s*'), '')
        .trim();
    if (cleaned.isNotEmpty) bullets.add(cleaned);
    if (bullets.length >= 3) break;
  }

  if (bullets.isEmpty) {
    return [text.trim()];
  }
  return bullets;
}

String coachAnalysisCacheKey(String userId, DateTime month) =>
    'coach_analysis_${userId}_${month.year}_${month.month}';

String coachAnalysisCacheTimeKey(String userId, DateTime month) =>
    'coach_analysis_time_${userId}_${month.year}_${month.month}';
