import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';

class DayFinance {
  const DayFinance({
    required this.income,
    required this.expense,
    required this.transactionCount,
  });

  final double income;
  final double expense;
  final int transactionCount;

  double get net => income - expense;
  bool get hasActivity => transactionCount > 0;
}

DayFinance summarizeDayTransactions(List<TransactionItem> items) {
  var income = 0.0;
  var expense = 0.0;
  for (final tx in items) {
    if (tx.isIncome) {
      income += tx.amount;
    } else {
      expense += tx.amount;
    }
  }
  return DayFinance(
    income: income,
    expense: expense,
    transactionCount: items.length,
  );
}

Map<DateTime, DayFinance> buildDayFinanceMap(MonthSummary summary) {
  final map = <DateTime, DayFinance>{};
  final grouped = <DateTime, List<TransactionItem>>{};

  for (final tx in summary.transactions) {
    final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
    grouped.putIfAbsent(key, () => []).add(tx);
  }

  for (final entry in grouped.entries) {
    map[entry.key] = summarizeDayTransactions(entry.value);
  }
  return map;
}

double maxExpenseInMonth(Map<DateTime, DayFinance> dayMap) {
  if (dayMap.isEmpty) return 0;
  return dayMap.values
      .map((d) => d.expense)
      .fold(0.0, (max, value) => value > max ? value : max);
}

String dayRelativeLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(day.year, day.month, day.day);
  final diff = today.difference(target).inDays;

  if (diff == 0) return 'Bugün';
  if (diff == 1) return 'Dün';
  if (diff == -1) return 'Yarın';
  return '';
}

List<TransactionItem> splitTransactions(List<TransactionItem> items) {
  return [...items]..sort((a, b) => b.date.compareTo(a.date));
}

List<TransactionItem> filterIncome(List<TransactionItem> items) =>
    items.where((tx) => tx.isIncome).toList();

List<TransactionItem> filterExpense(List<TransactionItem> items) =>
    items.where((tx) => !tx.isIncome).toList();
