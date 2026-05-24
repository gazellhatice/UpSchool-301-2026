import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _budgetKey(String userId, DateTime month) =>
    'monthly_budget_${userId}_${month.year}_${month.month}';

final monthlyBudgetProvider =
    StateNotifierProvider.family<MonthlyBudgetNotifier, double?, String>(
  (ref, userId) {
    return MonthlyBudgetNotifier(
      ref.watch(sharedPreferencesProvider),
      userId,
      ref,
    );
  },
);

class MonthlyBudgetNotifier extends StateNotifier<double?> {
  MonthlyBudgetNotifier(this._prefs, this.userId, this._ref) : super(null) {
    _ref.listen(selectedMonthProvider, (_, next) => _load(next));
    _load(_ref.read(selectedMonthProvider));
  }

  final SharedPreferences _prefs;
  final String userId;
  final Ref _ref;

  void _load(DateTime month) {
    state = _prefs.getDouble(_budgetKey(userId, month));
  }

  Future<void> setBudget(double? amount) async {
    final month = _ref.read(selectedMonthProvider);
    final key = _budgetKey(userId, month);
    if (amount == null || amount <= 0) {
      await _prefs.remove(key);
      state = null;
      return;
    }
    await _prefs.setDouble(key, amount);
    state = amount;
  }
}
