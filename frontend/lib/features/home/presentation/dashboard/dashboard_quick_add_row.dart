import 'package:flutter/material.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class DashboardQuickAddRow extends StatelessWidget {
  const DashboardQuickAddRow({
    super.key,
    required this.userId,
    required this.categories,
  });

  final String userId;
  final List<CategoryItem> categories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı ekle',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              ActionChip(
                avatar: Icon(category.icon, size: 16, color: category.color),
                label: Text(category.name),
                backgroundColor: palette.surfaceLight.withValues(alpha: 0.7),
                side: BorderSide(color: palette.border),
                onPressed: () => TransactionFormSheet.show(
                  context,
                  userId,
                  initialCategoryId: category.id,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
