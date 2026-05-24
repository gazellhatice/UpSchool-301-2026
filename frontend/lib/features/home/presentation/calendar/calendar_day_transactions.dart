import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar/calendar_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class CalendarDayTransactions extends ConsumerWidget {
  const CalendarDayTransactions({
    super.key,
    required this.userId,
    required this.selectedDay,
    required this.items,
  });

  final String userId;
  final DateTime selectedDay;
  final List<TransactionItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final sorted = splitTransactions(items);
    final incomes = filterIncome(sorted);
    final expenses = filterExpense(sorted);

    if (items.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 44,
              color: AppColors.primary.withValues(alpha: 0.65),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu gün için işlem yok',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Seçili güne gelir veya gider ekleyebilirsin.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => TransactionFormSheet.show(
                context,
                userId,
                initialDate: selectedDay,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Bu güne işlem ekle'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${items.length} işlem',
          style: theme.textTheme.labelLarge?.copyWith(
            color: palette.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (expenses.isNotEmpty) ...[
          _SectionTitle(title: 'Giderler', color: AppColors.danger),
          const SizedBox(height: 8),
          for (final tx in expenses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CalendarTransactionTile(
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
          const SizedBox(height: 8),
        ],
        if (incomes.isNotEmpty) ...[
          _SectionTitle(title: 'Gelirler', color: AppColors.accent),
          const SizedBox(height: 8),
          for (final tx in incomes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CalendarTransactionTile(
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
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _CalendarTransactionTile extends StatelessWidget {
  const _CalendarTransactionTile({
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
    final note = transaction.note.trim();
    final prefix = transaction.isIncome ? '+' : '-';
    final color = category?.color ?? AppColors.primary;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showConfirmDialog(
        context,
        title: 'İşlemi sil',
        message: 'Bu işlem kalıcı olarak silinecek.',
      ),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category?.icon ?? Icons.receipt_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      note.isNotEmpty
                          ? note
                          : DateFormat('HH:mm', 'tr_TR').format(transaction.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
