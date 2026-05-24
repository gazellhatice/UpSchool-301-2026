import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Alt navigasyon sekmesi (0: Özet, 1: Analiz, 2: Takvim, 3: Profil).
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
