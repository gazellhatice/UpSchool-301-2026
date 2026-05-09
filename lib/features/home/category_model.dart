import 'package:isar/isar.dart';

part 'category_model.g.dart';

/// Kategori tipi
enum CategoryType {
  income,  // Gelir kategorisi
  expense, // Gider kategorisi
}

/// Isar koleksiyonu — her kategori bir kayıt
@Collection()
class CategoryModel {
  Id id = Isar.autoIncrement;

  late String uid;          // Firebase kullanıcı ID'si
  late String name;         // Kategori adı
  late int iconCodePoint;   // MaterialIcon codePoint
  late int color;           // Color.value (int)
  late bool isDefault;      // Varsayılan kategori silinemez

  @enumerated
  late CategoryType type;
}

/// Varsayılan kategoriler — DB ilk açıldığında eklenir
class DefaultCategories {
  static List<Map<String, dynamic>> expense = [
    {'name': 'Yiyecek & İçecek', 'icon': 0xe532, 'color': 0xFFFF6B6B}, // restaurant
    {'name': 'Ulaşım',           'icon': 0xe531, 'color': 0xFF4ECDC4}, // directions_car
    {'name': 'Fatura',           'icon': 0xe8f0, 'color': 0xFFFFBE0B}, // receipt
    {'name': 'Sağlık',           'icon': 0xe548, 'color': 0xFFFF6392}, // favorite
    {'name': 'Eğlence',          'icon': 0xe040, 'color': 0xFFA855F7}, // sports_esports
    {'name': 'Alışveriş',        'icon': 0xe8cc, 'color': 0xFF06B6D4}, // shopping_bag
    {'name': 'Eğitim',           'icon': 0xe80c, 'color': 0xFF10B981}, // school
    {'name': 'Diğer',            'icon': 0xe88f, 'color': 0xFF94A3B8}, // category
  ];

  static List<Map<String, dynamic>> income = [
    {'name': 'Maaş',             'icon': 0xe263, 'color': 0xFF1DB954}, // payments
    {'name': 'Ek Gelir',         'icon': 0xe8e5, 'color': 0xFF10B981}, // trending_up
    {'name': 'Yatırım',          'icon': 0xe6de, 'color': 0xFFFFBE0B}, // show_chart
    {'name': 'Hediye',           'icon': 0xe906, 'color': 0xFFFF6392}, // card_giftcard
    {'name': 'Diğer',            'icon': 0xe88f, 'color': 0xFF94A3B8}, // category
  ];
}
