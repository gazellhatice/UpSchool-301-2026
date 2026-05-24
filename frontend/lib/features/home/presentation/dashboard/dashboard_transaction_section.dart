import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/home_navigation_provider.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/dashboard/dashboard_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class DashboardTransactionSection extends ConsumerWidget {
  const DashboardTransactionSection({
    super.key,
    required this.userId,
    required this.transactions,
  });

  final String userId;
  final List<TransactionItem> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final sorted = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final visible = sorted.take(15).toList();
    final groups = groupTransactionsByDay(visible, (tx) => tx.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son işlemler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${transactions.length} kayıt',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'Henüz işlem yok',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hızlı ekle chip\'lerinden veya + ile ilk işlemini kaydet.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else ...[
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                entry.key,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final tx in entry.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DashboardTransactionTile(
                  transaction: tx,
                  onTap: () => TransactionFormSheet.show(
                    context,
                    userId,
                    transaction: tx,
                  ),
                  onDelete: () => ref
                      .read(financeRepositoryProvider(userId))
                      .deleteTransaction(tx.id),
                ),
              ),
          ],
          if (transactions.length > visible.length)
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(homeTabIndexProvider.notifier).state = 2,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text('${transactions.length - visible.length} işlem daha — Takvim\'de gör'),
              ),
            ),
        ],
      ],
    );
  }
}

class _DashboardTransactionTile extends StatelessWidget {
  const _DashboardTransactionTile({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  final TransactionItem transaction;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final category = transaction.category;
    final prefix = transaction.isIncome ? '+' : '-';
    final color = category?.color ?? AppColors.primary;
    final icon = category?.icon ?? Icons.receipt_rounded;
    final note = transaction.note.trim();

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return showConfirmDialog(
          context,
          title: 'İşlemi sil',
          message: 'Bu işlem kalıcı olarak silinecek.',
        );
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'İşlem',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (note.isNotEmpty)
                      Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      )
                    else
                      Text(
                        DateFormat('HH:mm', 'tr_TR').format(transaction.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '$prefix${formatCurrency(transaction.amount)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: transaction.isIncome
                      ? AppColors.accent
                      : AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
