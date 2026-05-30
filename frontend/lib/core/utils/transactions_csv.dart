import 'package:intl/intl.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';

String buildTransactionsCsv(List<TransactionItem> transactions) {
  final buffer = StringBuffer('Tarih;Tür;Kategori;Tutar;Not\n');
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

  for (final tx in sorted) {
    final type = tx.isIncome ? 'Gelir' : 'Gider';
    final category = _escape(tx.category?.name ?? '');
    final note = _escape(tx.note);
    final amount = tx.amount.toStringAsFixed(2).replaceAll('.', ',');
    buffer.writeln(
      '${dateFormat.format(tx.date)};$type;$category;$amount;$note',
    );
  }

  return buffer.toString();
}

String _escape(String value) {
  final cleaned = value.replaceAll(';', ',').replaceAll('\n', ' ');
  return '"$cleaned"';
}
