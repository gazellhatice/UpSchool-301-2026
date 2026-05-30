import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';

class DashboardTransactionsTable extends StatelessWidget {
  const DashboardTransactionsTable({
    super.key,
    required this.transactions,
    required this.onTap,
    required this.onDelete,
  });

  final List<TransactionItem> transactions;
  final void Function(TransactionItem tx) onTap;
  final Future<void> Function(TransactionItem tx) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final sorted = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final visible = sorted.take(20).toList();

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columnSpacing: 24,
          headingTextStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: palette.textSecondary,
          ),
          columns: const [
            DataColumn(label: Text('Tarih')),
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Not')),
            DataColumn(label: Text('Tutar'), numeric: true),
            DataColumn(label: Text('')),
          ],
          rows: visible.map((tx) {
            final category = tx.category;
            final prefix = tx.isIncome ? '+' : '-';
            final amountColor =
                tx.isIncome ? AppColors.accent : AppColors.danger;

            return DataRow(
              onSelectChanged: (_) => onTap(tx),
              cells: [
                DataCell(
                  Text(
                    DateFormat('d MMM yyyy · HH:mm', 'tr_TR').format(tx.date),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category?.icon ?? Icons.receipt_rounded,
                        size: 18,
                        color: category?.color ?? AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(category?.name ?? '—'),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    tx.note.trim().isEmpty ? '—' : tx.note.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    '$prefix${formatCurrency(tx.amount)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: AppColors.danger,
                    tooltip: 'Sil',
                    onPressed: () async {
                      final ok = await showConfirmDialog(
                        context,
                        title: 'İşlemi sil',
                        message: 'Bu işlem kalıcı olarak silinecek.',
                      );
                      if (ok == true) await onDelete(tx);
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
