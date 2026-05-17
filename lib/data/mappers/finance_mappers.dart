import 'package:kisisel_harcama_kocu_1/data/local/app_database.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/category_item.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_item.dart';
import 'package:kisisel_harcama_kocu_1/domain/models/transaction_type.dart';

extension CategoryMapper on Category {
  CategoryItem toDomain() => CategoryItem(
        id: id,
        userId: userId,
        name: name,
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
        isDefault: isDefault,
        isIncome: isIncome,
        synced: synced,
        updatedAt: updatedAt,
      );
}

extension TransactionMapper on TransactionWithCategory {
  TransactionItem toDomain() => TransactionItem(
        id: transaction.id,
        userId: transaction.userId,
        amount: transaction.amount,
        type: TransactionType.fromValue(transaction.type),
        categoryId: transaction.categoryId,
        date: transaction.date,
        note: transaction.note,
        synced: transaction.synced,
        updatedAt: transaction.updatedAt,
        category: category?.toDomain(),
      );
}
