import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/features/categories/presentation/add_category_sheet.dart';

class ProfileCategoriesSection extends ConsumerWidget {
  const ProfileCategoriesSection({
    super.key,
    required this.userId,
    required this.onDeleteCategory,
  });

  final String userId;
  final Future<void> Function(CategoryItem category) onDeleteCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final categoriesAsync = ref.watch(categoriesProvider(userId));
    final month = ref.watch(selectedMonthProvider);
    final summary = ref
        .watch(monthSummaryProvider((userId: userId, month: month)))
        .valueOrNull;

    final usage = <String, int>{};
    for (final tx in summary?.transactions ?? const []) {
      usage[tx.categoryId] = (usage[tx.categoryId] ?? 0) + 1;
    }

    return categoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Kategoriler yüklenemedi: $e'),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Henüz kategori yok.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          );
        }

        final incomes = categories.where((c) => c.isIncome).toList();
        final expenses = categories.where((c) => !c.isIncome).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${categories.length} kategori',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => AddCategorySheet.show(context, userId),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Yeni'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (expenses.isNotEmpty) ...[
                _GroupTitle(title: 'Gider kategorileri', color: AppColors.danger),
                const SizedBox(height: 8),
                for (final category in expenses)
                  _CategoryTile(
                    category: category,
                    usageCount: usage[category.id] ?? 0,
                    onEdit: category.isDefault
                        ? null
                        : () => AddCategorySheet.show(
                              context,
                              userId,
                              category: category,
                            ),
                    onDelete: category.isDefault
                        ? null
                        : () => onDeleteCategory(category),
                  ),
                const SizedBox(height: 12),
              ],
              if (incomes.isNotEmpty) ...[
                _GroupTitle(title: 'Gelir kategorileri', color: AppColors.accent),
                const SizedBox(height: 8),
                for (final category in incomes)
                  _CategoryTile(
                    category: category,
                    usageCount: usage[category.id] ?? 0,
                    onEdit: category.isDefault
                        ? null
                        : () => AddCategorySheet.show(
                              context,
                              userId,
                              category: category,
                            ),
                    onDelete: category.isDefault
                        ? null
                        : () => onDeleteCategory(category),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.usageCount,
    this.onEdit,
    this.onDelete,
  });

  final CategoryItem category;
  final int usageCount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (category.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Varsayılan',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  usageCount > 0
                      ? 'Bu ay $usageCount işlem'
                      : 'Bu ay kullanılmadı',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!category.synced)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 16,
                color: AppColors.accentWarm,
              ),
            ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
