import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Uygulama boyunca tek AppDatabase instance'ı
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Widget tree yıkılınca DB bağlantısını kapat
  ref.onDispose(db.close);

  return db;
});
