import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/core/providers/app_providers.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_palette.dart';

/// Özet ve analiz sekmelerinde ortak ay seçici.
class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final month = ref.watch(selectedMonthProvider);
    final label = DateFormat('MMMM yyyy', 'tr_TR').format(month);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final canGoForward = month.isBefore(currentMonth);

    void shift(int delta) {
      final next = DateTime(month.year, month.month + delta);
      if (next.isAfter(currentMonth)) return;
      ref.read(selectedMonthProvider.notifier).state = next;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Önceki ay',
            onPressed: () => shift(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            visualDensity: VisualDensity.compact,
          ),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Sonraki ay',
            onPressed: canGoForward ? () => shift(1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
