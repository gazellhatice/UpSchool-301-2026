import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/stats/stats_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class StatsCategoryDetailSheet extends ConsumerWidget {
  const StatsCategoryDetailSheet({
    super.key,
    required this.userId,
    required this.month,
    required this.category,
  });

  final String userId;
  final DateTime month;
  final CategoryItem category;

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required DateTime month,
    required CategoryItem category,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatsCategoryDetailSheet(
        userId: userId,
        month: month,
        category: category,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final summary = ref
        .watch(monthSummaryProvider((userId: userId, month: month)))
        .valueOrNull;
    final transactions = summary == null
        ? const []
        : transactionsForCategory(
            summary: summary,
            categoryId: category.id,
          );
    final total = transactions.fold<double>(0, (s, tx) => s + tx.amount);
    final monthLabel = DateFormat('MMMM yyyy', 'tr_TR').format(month);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: palette.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$monthLabel · ${transactions.length} işlem',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: transactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Bu kategoride henüz işlem yok.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final note = tx.note.trim();
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: palette.border),
                        ),
                        tileColor: palette.surfaceLight.withValues(alpha: 0.35),
                        title: Text(
                          note.isEmpty ? 'İşlem' : note,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('d MMM, HH:mm', 'tr_TR').format(tx.date),
                        ),
                        trailing: Text(
                          '-${formatCurrency(tx.amount)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.danger,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          TransactionFormSheet.show(
                            context,
                            userId,
                            transaction: tx,
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                TransactionFormSheet.show(
                  context,
                  userId,
                  initialCategoryId: category.id,
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: Text('${category.name} ekle'),
            ),
          ),
        ],
      ),
    );
  }
}
