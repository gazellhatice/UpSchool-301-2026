import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../database/app_database.dart';
import '../database/db_provider.dart';

// ── Seçili ay provider ───────────────────────────────────────────
final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

// ── İşlem listesi provider ───────────────────────────────────────
final transactionsProvider =
    FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];

  final month = ref.watch(selectedMonthProvider);
  final db = ref.watch(dbProvider);

  return db.getTransactionsByMonth(user.uid, month);
});

// ── Özet provider ────────────────────────────────────────────────
class MonthlySummary {
  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
  });

  final double totalIncome;
  final double totalExpense;
  double get balance => totalIncome - totalExpense;
}

final monthlySummaryProvider = Provider.autoDispose<MonthlySummary>((ref) {
  final txAsync = ref.watch(transactionsProvider);

  return txAsync.when(
    data: (list) {
      double income = 0;
      double expense = 0;
      for (final tx in list) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }
      return MonthlySummary(totalIncome: income, totalExpense: expense);
    },
    loading: () => const MonthlySummary(totalIncome: 0, totalExpense: 0),
    error: (_, __) => const MonthlySummary(totalIncome: 0, totalExpense: 0),
  );
});