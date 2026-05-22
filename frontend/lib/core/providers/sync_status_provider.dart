import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _lastSyncKey = 'last_sync_at';

final lastSyncAtProvider =
    StateNotifierProvider<LastSyncNotifier, DateTime?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LastSyncNotifier(prefs);
});

class LastSyncNotifier extends StateNotifier<DateTime?> {
  LastSyncNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static DateTime? _load(SharedPreferences prefs) {
    final ms = prefs.getInt(_lastSyncKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markSynced() async {
    final now = DateTime.now();
    state = now;
    await _prefs.setInt(_lastSyncKey, now.millisecondsSinceEpoch);
  }

  void clear() {
    state = null;
    _prefs.remove(_lastSyncKey);
  }
}
