import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: '₺',
  decimalDigits: 0,
);

String formatCurrency(double value) => _currency.format(value);
