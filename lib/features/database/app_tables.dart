import 'package:drift/drift.dart';

// ─────────────────────────────────────────────────────────────────
// TRANSACTIONS TABLOSU
// ─────────────────────────────────────────────────────────────────
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text()();           // Firebase kullanıcı ID
  RealColumn get amount => real()();        // Tutar
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();  // İşlem tarihi
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text()();
  IntColumn get categoryIcon => integer()(); // IconData.codePoint
  IntColumn get categoryColor => integer()(); // Color.value
  TextColumn get type => text()();          // 'income' | 'expense'
}

// ─────────────────────────────────────────────────────────────────
// CATEGORIES TABLOSU
// ─────────────────────────────────────────────────────────────────
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text()();           // 'default' veya Firebase uid
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  IntColumn get color => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get type => text()();          // 'income' | 'expense'
}
