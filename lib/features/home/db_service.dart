import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'category_model.dart';
import 'transaction_model.dart';

/// Isar veritabanı — uygulama boyunca tek instance (singleton)
class DbService {
  DbService._();
  static final DbService instance = DbService._();

  Isar? _isar;

  /// DB'yi aç (main.dart'ta çağrılır)
  Future<void> init() async {
    if (_isar != null) return; // zaten açık

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema],
      directory: dir.path,
    );

    await _seedDefaultCategories();
  }

  Isar get isar {
    assert(_isar != null, 'DbService.init() henüz çağrılmadı!');
    return _isar!;
  }

  // ── İşlemler ──────────────────────────────────────────────────
  Future<List<TransactionModel>> getTransactionsByMonth(
      String uid, DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return isar.transactionModels
        .filter()
        .uidEqualTo(uid)
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  Future<void> saveTransaction(TransactionModel tx) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.put(tx);
    });
  }

  Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.delete(id);
    });
  }

  // ── Kategoriler ────────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories(
      String uid, CategoryType type) async {
    return isar.categoryModels
        .filter()
        .uidEqualTo(uid)
        .typeEqualTo(type)
        .findAll();
  }

  // ── Varsayılan kategorileri DB'ye ekle ─────────────────────────
  Future<void> _seedDefaultCategories() async {
    final count = await isar.categoryModels.count();
    if (count > 0) return; // zaten eklenmiş

    await isar.writeTxn(() async {
      // Gider kategorileri
      for (final data in DefaultCategories.expense) {
        await isar.categoryModels.put(CategoryModel()
          ..uid = 'default'
          ..name = data['name'] as String
          ..iconCodePoint = data['icon'] as int
          ..color = data['color'] as int
          ..isDefault = true
          ..type = CategoryType.expense);
      }
      // Gelir kategorileri
      for (final data in DefaultCategories.income) {
        await isar.categoryModels.put(CategoryModel()
          ..uid = 'default'
          ..name = data['name'] as String
          ..iconCodePoint = data['icon'] as int
          ..color = data['color'] as int
          ..isDefault = true
          ..type = CategoryType.income);
      }
    });
  }
}
