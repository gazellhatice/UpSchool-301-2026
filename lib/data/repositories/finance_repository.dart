import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/data/local/app_database.dart';
import 'package:kisisel_harcama_kocu_1/data/local/default_categories.dart';
import 'package:kisisel_harcama_kocu_1/data/mappers/finance_mappers.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_type.dart';

class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
    required this.transactions,
  });

  final double income;
  final double expense;
  final List<TransactionItem> transactions;

  double get balance => income - expense;
}

class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.amount,
    required this.percent,
  });

  final CategoryItem category;
  final double amount;
  final double percent;
}

class FinanceRepository {
  FinanceRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required String userId,
    Connectivity? connectivity,
  })  : _db = database,
        _firestore = firestore,
        _userId = userId,
        _connectivity = connectivity ?? Connectivity();

  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final String _userId;
  final Connectivity _connectivity;

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('users').doc(_userId).collection('categories');

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  Stream<List<CategoryItem>> watchCategories() {
    return (_db.select(_db.categories)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  Stream<MonthSummary> watchMonthSummary(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1)
        .subtract(const Duration(microseconds: 1));

    return _db.watchTransactionsBetween(_userId, start, end).map((rows) {
      final items = rows.map((r) => r.toDomain()).toList();
      var income = 0.0;
      var expense = 0.0;
      for (final tx in items) {
        if (tx.isIncome) {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }
      return MonthSummary(
        income: income,
        expense: expense,
        transactions: items,
      );
    });
  }

  Stream<List<TransactionItem>> watchDayTransactions(DateTime day) {
    return _db
        .watchTransactionsOnDay(_userId, day)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  Stream<List<CategoryStat>> watchExpenseStats(DateTime month) {
    return watchMonthSummary(month).map((summary) {
      final expenses = summary.transactions.where((t) => !t.isIncome);
      final total = summary.expense;
      if (total <= 0) return <CategoryStat>[];

      final map = <String, double>{};
      final categories = <String, CategoryItem>{};
      for (final tx in expenses) {
        map[tx.categoryId] = (map[tx.categoryId] ?? 0) + tx.amount;
        if (tx.category != null) {
          categories[tx.categoryId] = tx.category!;
        }
      }

      return map.entries.map((entry) {
        final category = categories[entry.key];
        if (category == null) return null;
        return CategoryStat(
          category: category,
          amount: entry.value,
          percent: (entry.value / total) * 100,
        );
      }).whereType<CategoryStat>().toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
    });
  }

  Future<void> initialize() async {
    final count = await (_db.selectOnly(_db.categories)
          ..addColumns([_db.categories.id.count()])
          ..where(_db.categories.userId.equals(_userId)))
        .getSingle();
    final categoryCount = count.read(_db.categories.id.count()) ?? 0;

    if (categoryCount == 0) {
      await _seedDefaultCategories();
    }

    await sync();
  }

  Future<void> _seedDefaultCategories() async {
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final seed in DefaultCategories.seeds) {
        batch.insert(
          _db.categories,
          CategoriesCompanion.insert(
            id: DefaultCategories.newId(),
            userId: _userId,
            name: seed.name,
            iconCodePoint: seed.icon.codePoint,
            colorValue: seed.color.value,
            isDefault: Value(seed.isDefault),
            synced: const Value(false),
            updatedAt: now,
          ),
        );
      }
    });
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String note = '',
  }) async {
    final now = DateTime.now();
    final id = DefaultCategories.newId();

    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: id,
            userId: _userId,
            amount: amount,
            type: type.value,
            categoryId: categoryId,
            date: date,
            note: Value(note),
            synced: const Value(false),
            updatedAt: now,
          ),
        );

    await _trySync();
  }

  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();

    if (await _isOnline()) {
      try {
        await _transactionsRef.doc(id).delete();
      } catch (_) {
        // Offline veya ağ hatası — yerel silme yeterli.
      }
    }
  }

  Future<void> addCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: DefaultCategories.newId(),
            userId: _userId,
            name: name,
            iconCodePoint: icon.codePoint,
            colorValue: color.value,
            isDefault: const Value(false),
            synced: const Value(false),
            updatedAt: now,
          ),
        );
    await _trySync();
  }

  Future<void> sync() async {
    if (!await _isOnline()) return;
    await _pullRemote();
    await _pushLocal();
  }

  Future<void> _trySync() async {
    if (await _isOnline()) {
      await sync();
    }
  }

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> _pushLocal() async {
    final unsyncedCategories = await _db.getUnsyncedCategories(_userId);
    for (final category in unsyncedCategories) {
      await _categoriesRef.doc(category.id).set({
        'name': category.name,
        'iconCodePoint': category.iconCodePoint,
        'colorValue': category.colorValue,
        'isDefault': category.isDefault,
        'updatedAt': Timestamp.fromDate(category.updatedAt),
      });
      await (_db.update(_db.categories)..where((t) => t.id.equals(category.id)))
          .write(const CategoriesCompanion(synced: Value(true)));
    }

    final unsyncedTransactions =
        await _db.getUnsyncedTransactions(_userId);
    for (final row in unsyncedTransactions) {
      final tx = row.transaction;
      await _transactionsRef.doc(tx.id).set({
        'amount': tx.amount,
        'type': tx.type,
        'categoryId': tx.categoryId,
        'date': Timestamp.fromDate(tx.date),
        'note': tx.note,
        'updatedAt': Timestamp.fromDate(tx.updatedAt),
      });
      await (_db.update(_db.transactions)..where((t) => t.id.equals(tx.id)))
          .write(const TransactionsCompanion(synced: Value(true)));
    }
  }

  Future<void> _pullRemote() async {
    final remoteCategories = await _categoriesRef.get();
    for (final doc in remoteCategories.docs) {
      final data = doc.data();
      final updatedAt =
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

      final existing = await (_db.select(_db.categories)
            ..where((t) => t.id.equals(doc.id)))
          .getSingleOrNull();

      if (existing == null || existing.updatedAt.isBefore(updatedAt)) {
        await _db.into(_db.categories).insertOnConflictUpdate(
              CategoriesCompanion(
                id: Value(doc.id),
                userId: Value(_userId),
                name: Value(data['name'] as String? ?? 'Diğer'),
                iconCodePoint:
                    Value(data['iconCodePoint'] as int? ?? Icons.category.codePoint),
                colorValue: Value(data['colorValue'] as int? ?? 0xFF9AA3B8),
                isDefault: Value(data['isDefault'] as bool? ?? false),
                synced: const Value(true),
                updatedAt: Value(updatedAt),
              ),
            );
      }
    }

    final remoteTransactions = await _transactionsRef.get();
    for (final doc in remoteTransactions.docs) {
      final data = doc.data();
      final updatedAt =
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

      final existing = await (_db.select(_db.transactions)
            ..where((t) => t.id.equals(doc.id)))
          .getSingleOrNull();

      if (existing == null || existing.updatedAt.isBefore(updatedAt)) {
        await _db.into(_db.transactions).insertOnConflictUpdate(
              TransactionsCompanion(
                id: Value(doc.id),
                userId: Value(_userId),
                amount: Value((data['amount'] as num).toDouble()),
                type: Value(data['type'] as int? ?? 0),
                categoryId: Value(data['categoryId'] as String),
                date: Value((data['date'] as Timestamp).toDate()),
                note: Value(data['note'] as String? ?? ''),
                synced: const Value(true),
                updatedAt: Value(updatedAt),
              ),
            );
      }
    }
  }
}
