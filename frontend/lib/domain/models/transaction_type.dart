enum TransactionType {
  expense(0),
  income(1);

  const TransactionType(this.value);
  final int value;

  static TransactionType fromValue(int value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.expense,
    );
  }

  bool get isIncome => this == TransactionType.income;
}
