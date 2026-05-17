import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';

class AddCategorySheet extends ConsumerStatefulWidget {
  const AddCategorySheet({super.key, required this.userId});

  final String userId;

  static Future<void> show(BuildContext context, String userId) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddCategorySheet(userId: userId),
    );
  }

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  final _nameController = TextEditingController();
  IconData _icon = Icons.label_rounded;
  Color _color = AppColors.primary;
  bool _saving = false;

  static const _iconOptions = [
    Icons.restaurant_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
    Icons.pets_rounded,
    Icons.card_giftcard_rounded,
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(financeRepositoryProvider(widget.userId)).addCategory(
            name: name,
            icon: _icon,
            color: _color,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yeni kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Kategori adı'),
            ),
            const SizedBox(height: 16),
            Text(
              'İkon',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _iconOptions.map((icon) {
                final selected = _icon == icon;
                return ChoiceChip(
                  selected: selected,
                  label: Icon(icon),
                  onSelected: (_) => setState(() => _icon = icon),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Renk',
              style: Theme.of(context).textTheme.labelLarge,
            ),
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
                        color: selected ? Colors.white : Colors.transparent,
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
              child: Text(_saving ? 'Kaydediliyor...' : 'Kategori ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
