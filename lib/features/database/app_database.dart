import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_tables.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────────────────────
// VERİTABANI — Drift code-gen ile üretilir
// ─────────────────────────────────────────────────────────────────
@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultCategories();
        },
      );

  // ── İşlemler ────────────────────────────────────────────────────

  /// Belirli kullanıcı + ay bazında işlemleri getirir (yeniden eskiye)
  Future<List<Transaction>> getTransactionsByMonth(
      String uid, DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return (select(transactions)
          ..where((t) => t.uid.equals(uid))
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Yeni işlem ekle veya güncelle
  Future<int> saveTransaction(TransactionsCompanion entry) =>
      into(transactions).insertOnConflictUpdate(entry);

  /// İşlem sil
  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // ── Kategoriler ─────────────────────────────────────────────────

  /// Kullanıcıya ait + varsayılan kategorileri getir
  Future<List<Category>> getCategories(String uid, String type) {
    return (select(categories)
          ..where((c) =>
              c.uid.equals(uid) | c.uid.equals('default'))
          ..where((c) => c.type.equals(type)))
        .get();
  }

  Future<int> saveCategory(CategoriesCompanion entry) =>
      into(categories).insertOnConflictUpdate(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  // ── Varsayılan kategoriler ──────────────────────────────────────
  Future<void> _seedDefaultCategories() async {
    final expenseData = [
      {'name': 'Yiyecek & İçecek', 'icon': 0xe532, 'color': 0xFFFF6B6B},
      {'name': 'Ulaşım',           'icon': 0xe531, 'color': 0xFF4ECDC4},
      {'name': 'Fatura',           'icon': 0xe8f0, 'color': 0xFFFFBE0B},
      {'name': 'Sağlık',           'icon': 0xe548, 'color': 0xFFFF6392},
      {'name': 'Eğlence',          'icon': 0xe040, 'color': 0xFFA855F7},
      {'name': 'Alışveriş',        'icon': 0xe8cc, 'color': 0xFF06B6D4},
      {'name': 'Eğitim',           'icon': 0xe80c, 'color': 0xFF10B981},
      {'name': 'Diğer',            'icon': 0xe88f, 'color': 0xFF94A3B8},
    ];

    final incomeData = [
      {'name': 'Maaş',    'icon': 0xe263, 'color': 0xFF1DB954},
      {'name': 'Ek Gelir','icon': 0xe8e5, 'color': 0xFF10B981},
      {'name': 'Yatırım', 'icon': 0xe6de, 'color': 0xFFFFBE0B},
      {'name': 'Hediye',  'icon': 0xe906, 'color': 0xFFFF6392},
      {'name': 'Diğer',   'icon': 0xe88f, 'color': 0xFF94A3B8},
    ];

    for (final d in expenseData) {
      await into(categories).insert(CategoriesCompanion.insert(
        uid: 'default',
        name: d['name'] as String,
        iconCodePoint: d['icon'] as int,
        color: d['color'] as int,
        isDefault: const Value(true),
        type: 'expense',
      ));
    }

    for (final d in incomeData) {
      await into(categories).insert(CategoriesCompanion.insert(
        uid: 'default',
        name: d['name'] as String,
        iconCodePoint: d['icon'] as int,
        color: d['color'] as int,
        isDefault: const Value(true),
        type: 'income',
      ));
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// VERİTABANI BAĞLANTISI
// ─────────────────────────────────────────────────────────────────
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mmas.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
