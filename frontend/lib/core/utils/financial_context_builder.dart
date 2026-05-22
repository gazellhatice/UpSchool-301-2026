import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/services/coach_api_service.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';

FinancialContext buildFinancialContext({
  required DateTime month,
  required MonthSummary summary,
  required List<CategoryStat> stats,
}) {
  final monthLabel = DateFormat('MMMM yyyy', 'tr_TR').format(month);
  final usagePercent =
      summary.income > 0 ? (summary.expense / summary.income) * 100 : 0.0;

  final sorted = List<TransactionItem>.from(summary.transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  return FinancialContext(
    month: monthLabel,
    income: summary.income,
    expense: summary.expense,
    balance: summary.balance,
    usagePercent: usagePercent,
    topCategories: stats
        .map(
          (s) => CategoryContext(
            name: s.category.name,
            amount: s.amount,
            percent: s.percent,
          ),
        )
        .toList(),
    recentTransactions: sorted.take(8).map((tx) {
      return TransactionContext(
        date: DateFormat('d MMM', 'tr_TR').format(tx.date),
        amount: tx.amount,
        type: tx.isIncome ? 'income' : 'expense',
        category: tx.category?.name ?? 'Diğer',
        note: tx.note,
      );
    }).toList(),
  );
}
