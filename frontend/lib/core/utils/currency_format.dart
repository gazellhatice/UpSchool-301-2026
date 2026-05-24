import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: '₺',
  decimalDigits: 0,
);

String formatCurrency(double value) => _currency.format(value);

String formatCompactCurrency(double value) {
  if (value >= 1000000) {
    return '₺${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '₺${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}K';
  }
  return '₺${value.round()}';
}
