import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/services/coach_api_service.dart';
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

final coachApiServiceProvider = Provider<CoachApiService>((ref) {
  final service = CoachApiService();
  ref.onDispose(service.dispose);
  return service;
});

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

final todaySummaryProvider = StreamProvider.family<TodaySummary, String>(
  (ref, userId) {
    return ref.watch(financeRepositoryProvider(userId)).watchTodaySummary();
  },
);

final previousMonthSummaryProvider =
    StreamProvider.family<MonthSummary, ({String userId, DateTime month})>(
  (ref, params) {
    final previous = DateTime(params.month.year, params.month.month - 1);
    return ref
        .watch(financeRepositoryProvider(params.userId))
        .watchMonthSummary(previous);
  },
);

final weeklyExpenseTrendProvider =
    StreamProvider.family<List<DailyExpenseTotal>, String>(
  (ref, userId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return ref
        .watch(financeRepositoryProvider(userId))
        .watchDailyExpenseTotals(start, end);
  },
);

final monthlyExpenseTrendProvider =
    StreamProvider.family<List<DailyExpenseTotal>, ({String userId, DateTime month})>(
  (ref, params) {
    final month = params.month;
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1)
        .subtract(const Duration(microseconds: 1));
    return ref
        .watch(financeRepositoryProvider(params.userId))
        .watchDailyExpenseTotals(start, end);
  },
);

/// Sık kullanılan gider kategorileri (hızlı ekleme chip'leri).
final quickExpenseCategoriesProvider =
    Provider.family<List<CategoryItem>, String>((ref, userId) {
  final categories = ref.watch(categoriesProvider(userId)).valueOrNull ?? [];
  final summary = ref
      .watch(monthSummaryProvider((
        userId: userId,
        month: ref.watch(selectedMonthProvider),
      )))
      .valueOrNull;

  final expenseCategories =
      categories.where((c) => !c.isIncome).toList(growable: false);
  if (expenseCategories.isEmpty) return const [];

  final counts = <String, int>{};
  for (final tx in summary?.transactions ?? const []) {
    if (tx.isIncome) continue;
    counts[tx.categoryId] = (counts[tx.categoryId] ?? 0) + 1;
  }

  final picked = <CategoryItem>[];
  final sortedIds = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

  for (final id in sortedIds) {
    final match = expenseCategories.where((c) => c.id == id);
    if (match.isEmpty) continue;
    picked.add(match.first);
    if (picked.length >= 4) return picked;
  }

  const defaults = ['Yemek', 'Ulaşım', 'Eğlence', 'Diğer'];
  for (final name in defaults) {
    if (picked.length >= 4) break;
    final match = expenseCategories.where((c) => c.name == name);
    if (match.isEmpty) continue;
    if (picked.any((p) => p.id == match.first.id)) continue;
    picked.add(match.first);
  }

  for (final category in expenseCategories) {
    if (picked.length >= 4) break;
    if (picked.any((p) => p.id == category.id)) continue;
    picked.add(category);
  }

  return picked;
});
