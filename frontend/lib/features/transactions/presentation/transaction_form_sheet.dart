import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/adaptive_form_container.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/adaptive_overlay.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_type.dart';

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    super.key,
    required this.userId,
    this.transaction,
    this.initialCategoryId,
    this.initialDate,
  });

  final String userId;
  final TransactionItem? transaction;
  final String? initialCategoryId;
  final DateTime? initialDate;

  static Future<void> show(
    BuildContext context,
    String userId, {
    TransactionItem? transaction,
    String? initialCategoryId,
    DateTime? initialDate,
  }) {
    return showAdaptiveOverlay<void>(
      context: context,
      maxWidth: 480,
      builder: (_) => TransactionFormSheet(
        userId: userId,
        transaction: transaction,
        initialCategoryId: initialCategoryId,
        initialDate: initialDate,
      ),
    );
  }

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _type;
  String? _categoryId;
  late DateTime _date;
  bool _saving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController = TextEditingController(
      text: tx != null ? tx.amount.toString() : '',
    );
    _noteController = TextEditingController(text: tx?.note ?? '');
    _type = tx?.type ?? TransactionType.expense;
    _categoryId = tx?.categoryId ?? widget.initialCategoryId;
    _date = tx?.date ?? widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _showError('Geçerli bir tutar gir.');
      return;
    }
    if (_categoryId == null) {
      _showError('Kategori seç.');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(financeRepositoryProvider(widget.userId));
      if (_isEditing) {
        await repo.updateTransaction(
          id: widget.transaction!.id,
          amount: amount,
          type: _type,
          categoryId: _categoryId!,
          date: _date,
          note: _noteController.text.trim(),
        );
      } else {
        await repo.addTransaction(
          amount: amount,
          type: _type,
          categoryId: _categoryId!,
          date: _date,
          note: _noteController.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError('Kayıt başarısız: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider(widget.userId));

    return AdaptiveFormContainer(
      title: _isEditing ? 'İşlemi düzenle' : 'Yeni işlem',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Gider'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Gelir'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  setState(() {
                    _type = value.first;
                    _categoryId = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tutar (₺)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Kategoriler yüklenemedi: $e'),
                data: (categories) {
                  final filtered = categories
                      .where((c) => c.isIncome == _type.isIncome)
                      .toList();

                  if (_categoryId != null &&
                      !filtered.any((c) => c.id == _categoryId)) {
                    _categoryId =
                        filtered.isNotEmpty ? filtered.first.id : null;
                  }
                  _categoryId ??=
                      filtered.isNotEmpty ? filtered.first.id : null;

                  return DropdownButtonFormField<String>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: filtered
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              children: [
                                Icon(c.icon, color: c.color, size: 20),
                                const SizedBox(width: 10),
                                Text(c.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value),
                  );
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Tarih'),
                subtitle:
                    Text(DateFormat('d MMMM yyyy', 'tr_TR').format(_date)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not (isteğe bağlı)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Güncelle' : 'Kaydet'),
          ),
        ],
      ),
    );
  }
}
