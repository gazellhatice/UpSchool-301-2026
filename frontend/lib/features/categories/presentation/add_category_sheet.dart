import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/layout/adaptive_overlay.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/data/repositories/finance_repository.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';

class AddCategorySheet extends ConsumerStatefulWidget {
  const AddCategorySheet({
    super.key,
    required this.userId,
    this.category,
  });

  final String userId;
  final CategoryItem? category;

  static Future<void> show(
    BuildContext context,
    String userId, {
    CategoryItem? category,
  }) {
    return showAdaptiveOverlay<void>(
      context: context,
      maxWidth: 460,
      builder: (_) => AddCategorySheet(userId: userId, category: category),
    );
  }

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  late final TextEditingController _nameController;
  late IconData _icon;
  late Color _color;
  late bool _isIncome;
  bool _saving = false;

  bool get _isEditing => widget.category != null;

  static const _iconOptions = [
    Icons.restaurant_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
    Icons.pets_rounded,
    Icons.card_giftcard_rounded,
    Icons.payments_rounded,
    Icons.laptop_mac_rounded,
  ];

  static const _colorOptions = [
    AppColors.primary,
    AppColors.accent,
    AppColors.accentWarm,
    AppColors.danger,
    AppColors.primaryGlow,
    Color(0xFF9AA3B8),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _icon = c?.icon ?? Icons.label_rounded;
    _color = c?.color ?? AppColors.primary;
    _isIncome = c?.isIncome ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Kategori adı gerekli.');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(financeRepositoryProvider(widget.userId));
      if (_isEditing) {
        await repo.updateCategory(
          id: widget.category!.id,
          name: name,
          icon: _icon,
          color: _color,
          isIncome: _isIncome,
        );
      } else {
        await repo.addCategory(
          name: name,
          icon: _icon,
          color: _color,
          isIncome: _isIncome,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FinanceException catch (e) {
      _showError(e.message);
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
    final palette = context.palette;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isDefault = widget.category?.isDefault ?? false;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Kategoriyi düzenle' : 'Yeni kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              readOnly: isDefault,
              decoration: InputDecoration(
                labelText: 'Kategori adı',
                helperText: isDefault ? 'Varsayılan kategorilerin adı değiştirilemez' : null,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Gider')),
                ButtonSegment(value: true, label: Text('Gelir')),
              ],
              selected: {_isIncome},
              onSelectionChanged: (v) => setState(() => _isIncome = v.first),
            ),
            const SizedBox(height: 16),
            Text('İkon', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _iconOptions.map((icon) {
                return ChoiceChip(
                  selected: _icon == icon,
                  label: Icon(icon),
                  onSelected: (_) => setState(() => _icon = icon),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Renk', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colorOptions.map((color) {
                final selected = _color == color;
                return GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? palette.textPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Kaydediliyor...' : (_isEditing ? 'Güncelle' : 'Kategori ekle')),
            ),
          ],
        ),
      ),
    );
  }
}
