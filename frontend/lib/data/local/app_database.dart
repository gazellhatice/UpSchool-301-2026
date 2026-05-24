import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  IntColumn get colorValue => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  RealColumn get amount => real()();
  IntColumn get type => integer()();
  TextColumn get categoryId => text().references(Categories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Çevrimdışı silinen kayıtların Firestore ile eşitlenmesi için kuyruk.
class PendingDeletes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get collection => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Categories, Transactions, PendingDeletes])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(categories, categories.isIncome);
            await customStatement(
              "UPDATE categories SET is_income = 1 "
              "WHERE name IN ('Maaş', 'Ek Gelir')",
            );
            await migrator.createTable(pendingDeletes);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'harcama_kocu_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  Stream<List<TransactionWithCategory>> watchTransactionsBetween(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    final query = select(transactions).join([
      leftOuterJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ])
      ..where(transactions.userId.equals(userId))
      ..where(transactions.date.isBetweenValues(start, end))
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map(_mapJoinedTransactions);
  }

  Stream<List<TransactionWithCategory>> watchTransactionsOnDay(
    String userId,
    DateTime day,
  ) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));
    return watchTransactionsBetween(userId, start, end);
  }

  Future<List<Category>> getCategoriesForUser(String userId) {
    return (select(categories)
          ..where((t) => t.userId.equals(userId)))
        .get();
  }

  Future<List<TransactionWithCategory>> getUnsyncedTransactions(
    String userId,
  ) async {
    final query = select(transactions).join([
      leftOuterJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ])
      ..where(transactions.userId.equals(userId))
      ..where(transactions.synced.equals(false));

    final rows = await query.get();
    return _mapJoinedTransactions(rows);
  }

  Future<List<Category>> getUnsyncedCategories(String userId) {
    return (select(categories)
          ..where((t) => t.userId.equals(userId) & t.synced.equals(false)))
        .get();
  }

  Future<List<PendingDelete>> getPendingDeletes(String userId) {
    return (select(pendingDeletes)
          ..where((t) => t.userId.equals(userId)))
        .get();
  }

  Future<void> clearUserData(String userId) async {
    await (delete(transactions)..where((t) => t.userId.equals(userId))).go();
    await (delete(categories)..where((t) => t.userId.equals(userId))).go();
    await (delete(pendingDeletes)..where((t) => t.userId.equals(userId))).go();
  }

  List<TransactionWithCategory> _mapJoinedTransactions(
    List<TypedResult> rows,
  ) {
    return rows.map((row) {
      final tx = row.readTable(transactions);
      final cat = row.readTableOrNull(categories);
      return TransactionWithCategory(transaction: tx, category: cat);
    }).toList();
  }
}

class TransactionWithCategory {
  const TransactionWithCategory({
    required this.transaction,
    this.category,
  });

  final Transaction transaction;
  final Category? category;
}
