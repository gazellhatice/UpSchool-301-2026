import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar/calendar_board.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar/calendar_day_transactions.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar/calendar_header.dart';
import 'package:kisisel_harcama_kocu_1/features/home/presentation/calendar/calendar_utils.dart';
import 'package:kisisel_harcama_kocu_1/features/transactions/presentation/transaction_form_sheet.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key, required this.userId, required this.user});

  final String userId;
  final User user;

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _focusedDay = DateTime.now();

  void _goToToday() {
    final now = DateTime.now();
    ref.read(calendarDayProvider.notifier).state = now;
    setState(() => _focusedDay = now);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(calendarDayProvider);
    final month = DateTime(_focusedDay.year, _focusedDay.month);
    final monthSummaryAsync = ref.watch(
      monthSummaryProvider((userId: widget.userId, month: month)),
    );
    final transactionsAsync = ref.watch(
      dayTransactionsProvider((userId: widget.userId, day: selectedDay)),
    );

    final monthSummary = monthSummaryAsync.valueOrNull;
    final dayFinanceMap = monthSummary == null
        ? <DateTime, DayFinance>{}
        : buildDayFinanceMap(monthSummary);
    final maxExpense = maxExpenseInMonth(dayFinanceMap);
    final dayItems = transactionsAsync.valueOrNull ?? const [];
    final daySummary = summarizeDayTransactions(dayItems);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        CalendarHeader(
          user: widget.user,
          focusedMonth: _focusedDay,
          onTodayTap: _goToToday,
        ),
        if (monthSummary != null) ...[
          const SizedBox(height: 16),
          CalendarMonthOverview(
            summary: monthSummary,
            activeDays: dayFinanceMap.length,
          ),
        ],
        const SizedBox(height: 16),
        CalendarBoard(
          focusedDay: _focusedDay,
          selectedDay: selectedDay,
          dayFinanceMap: dayFinanceMap,
          maxExpense: maxExpense,
          onDaySelected: (selected, focused) {
            ref.read(calendarDayProvider.notifier).state = selected;
            setState(() => _focusedDay = focused);
          },
          onPageChanged: (focused) => setState(() => _focusedDay = focused),
        ),
        const SizedBox(height: 20),
        CalendarDaySummary(
          selectedDay: selectedDay,
          summary: daySummary,
          onAddTap: () => TransactionFormSheet.show(
            context,
            widget.userId,
            initialDate: selectedDay,
          ),
        ),
        const SizedBox(height: 20),
        transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Yüklenemedi: $e'),
          data: (items) => CalendarDayTransactions(
            userId: widget.userId,
            selectedDay: selectedDay,
            items: items,
          ),
        ),
      ],
    );
  }
}
