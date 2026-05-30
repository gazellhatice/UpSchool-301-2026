import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/adaptive_overlay.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/budget_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';

class BudgetEditSheet extends ConsumerStatefulWidget {
  const BudgetEditSheet({
    super.key,
    required this.userId,
    required this.currentBudget,
    required this.monthExpense,
  });

  final String userId;
  final double? currentBudget;
  final double monthExpense;

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required double? currentBudget,
    required double monthExpense,
  }) {
    return showAdaptiveOverlay<void>(
      context: context,
      maxWidth: 440,
      builder: (_) => BudgetEditSheet(
        userId: userId,
        currentBudget: currentBudget,
        monthExpense: monthExpense,
      ),
    );
  }

  @override
  ConsumerState<BudgetEditSheet> createState() => _BudgetEditSheetState();
}

class _BudgetEditSheetState extends ConsumerState<BudgetEditSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentBudget?.round().toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save(double? amount) async {
    setState(() => _saving = true);
    await ref.read(monthlyBudgetProvider(widget.userId).notifier).setBudget(amount);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aylık bütçe hedefi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ay ${formatCurrency(widget.monthExpense)} harcadın. '
              'Bütçe belirlersen ilerleme çubuğu buna göre güncellenir.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Aylık harcama limiti (₺)',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () {
                      final raw = _controller.text.replaceAll(',', '.');
                      final amount = double.tryParse(raw);
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Geçerli bir bütçe tutarı gir.'),
                          ),
                        );
                        return;
                      }
                      _save(amount);
                    },
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
            if (widget.currentBudget != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : () => _save(null),
                child: const Text('Bütçeyi kaldır'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
