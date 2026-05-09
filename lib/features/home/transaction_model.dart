import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

/// İşlem türü: Gelir mi, Gider mi
enum TransactionType {
  income,  // Gelir
  expense, // Gider
}

/// Isar koleksiyonu — her işlem bir kayıt
@Collection()
class TransactionModel {
  Id id = Isar.autoIncrement;

  late String uid;           // Firebase kullanıcı ID'si (kimin işlemi)
  late double amount;        // Tutar
  late String note;          // Açıklama / not
  late DateTime date;        // İşlem tarihi
  late String categoryId;    // Kategori ID'si
  late String categoryName;  // Kategori adı (denormalized, hız için)
  late String categoryIcon;  // Kategori ikonu (MaterialIcon codePoint string)
  late int categoryColor;    // Kategori rengi (Color.value)

  @enumerated
  late TransactionType type; // Gelir / Gider
}
