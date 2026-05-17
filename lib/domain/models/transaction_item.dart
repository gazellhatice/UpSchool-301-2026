import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_type.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.note,
    required this.synced,
    required this.updatedAt,
    this.category,
  });

  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String note;
  final bool synced;
  final DateTime updatedAt;
  final CategoryItem? category;

  bool get isIncome => type.isIncome;
}
