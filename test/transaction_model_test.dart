import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionModel', () {
    test('toMap and fromMap keep every field', () {
      final original = TransactionModel(
        id: 7,
        title: 'Monthly salary',
        amount: 45000.5,
        category: 'Salary',
        type: TransactionType.income,
        date: DateTime(2026, 11, 4),
      );

      final restored = TransactionModel.fromMap(original.toMap());

      expect(restored.id, 7);
      expect(restored.title, 'Monthly salary');
      expect(restored.amount, 45000.5);
      expect(restored.category, 'Salary');
      expect(restored.type, TransactionType.income);
      expect(restored.date, DateTime(2026, 11, 4));
    });

    test('toMap leaves id out for a new transaction', () {
      final fresh = TransactionModel(
        title: 'Lunch',
        amount: 120,
        category: 'Food & Dining',
        type: TransactionType.expense,
        date: DateTime(2026, 11, 4),
      );

      expect(fresh.toMap().containsKey('id'), isFalse);
    });
  });
}