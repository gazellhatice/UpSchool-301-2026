import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_colors.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';
import 'package:kisisel_harcama_kocu_1/core/utils/currency_format.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/confirm_dialog.dart';
import 'package:kisisel_harcama_kocu_1/core/widgets/glass_card.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final selectedDay = ref.watch(calendarDayProvider);
    final month = DateTime(_focusedDay.year, _focusedDay.month);
    final monthSummaryAsync = ref.watch(
      monthSummaryProvider((userId: widget.userId, month: month)),
    );
    final transactionsAsync = ref.watch(
      dayTransactionsProvider((userId: widget.userId, day: selectedDay)),
    );

    final daysWithTx = monthSummaryAsync.valueOrNull?.daysWithTransactions ??
        <DateTime>{};

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text(
          'Takvim',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            locale: 'tr_TR',
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return daysWithTx.any((d) => isSameDay(d, key)) ? ['•'] : [];
            },
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              markersMaxCount: 1,
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientCard),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: palette.textSecondary),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            onDaySelected: (selected, focused) {
              ref.read(calendarDayProvider.notifier).state = selected;
              setState(() => _focusedDay = focused);
            },
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDay),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Yüklenemedi: $e'),
          data: (items) {
            if (items.isEmpty) {
              return GlassCard(
                child: Column(
                  children: [
                    Text(
                      'Bu gün için işlem yok.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => TransactionFormSheet.show(
                        context,
                        widget.userId,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('İşlem ekle'),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: items.map((tx) {
                final cat = tx.category;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => TransactionFormSheet.show(
                        context,
                        widget.userId,
                        transaction: tx,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat?.icon ?? Icons.receipt_rounded,
                            color: cat?.color ?? AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat?.name ?? 'İşlem',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (tx.note.isNotEmpty)
                                  Text(
                                    tx.note,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${tx.isIncome ? '+' : '-'}${formatCurrency(tx.amount)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tx.isIncome
                                  ? AppColors.accent
                                  : AppColors.danger,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              final ok = await showConfirmDialog(
                                context,
                                title: 'İşlemi sil',
                                message: 'Bu işlem silinecek.',
                              );
                              if (ok) {
                                await ref
                                    .read(
                                      financeRepositoryProvider(widget.userId),
                                    )
                                    .deleteTransaction(tx.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
