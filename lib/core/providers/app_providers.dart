import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/data/local/app_database.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';
import 'package:kisisel_harcama_kocu_1/features/auth/data/auth_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final financeRepositoryProvider =
Provider.family<FinanceRepository, String>((ref, userId) {
  return FinanceRepository(
    database: ref.watch(databaseProvider),
    firestore: ref.watch(firestoreProvider),
    userId: userId,
  );
});

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final monthSummaryProvider =
    StreamProvider.family<MonthSummary, ({String userId, DateTime month})>(
  (ref, params) {
    return ref
        .watch(financeRepositoryProvider(params.userId))
        .watchMonthSummary(params.month);
  },
);

final expenseStatsProvider =
    StreamProvider.family<List<CategoryStat>, ({String userId, DateTime month})>(
  (ref, params) {
    return ref
        .watch(financeRepositoryProvider(params.userId))
        .watchExpenseStats(params.month);
  },
);

final categoriesProvider = StreamProvider.family<List<CategoryItem>, String>(
  (ref, userId) {
    return ref.watch(financeRepositoryProvider(userId)).watchCategories();
  },
);

final calendarDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dayTransactionsProvider =
    StreamProvider.family<List<TransactionItem>, ({String userId, DateTime day})>(
  (ref, params) {
    return ref
        .watch(financeRepositoryProvider(params.userId))
        .watchDayTransactions(params.day);
  },
);
