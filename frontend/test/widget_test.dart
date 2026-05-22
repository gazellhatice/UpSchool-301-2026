import 'package:flutter_test/flutter_test.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_type.dart';

void main() {
  test('TransactionType.fromValue maps known values', () {
    expect(TransactionType.fromValue(0), TransactionType.expense);
    expect(TransactionType.fromValue(1), TransactionType.income);
  });

  test('TransactionType.fromValue falls back to expense', () {
    expect(TransactionType.fromValue(99), TransactionType.expense);
  });
}
