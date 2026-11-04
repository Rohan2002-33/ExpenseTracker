import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  TransactionModel? findById(int id) {
    for (final transaction in _transactions) {
      if (transaction.id == id) return transaction;
    }
    return null;
  }

  Future<void> load() async {
    try {
      _transactions = await _db.getAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _db.insert(transaction);
    await load();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.update(transaction);
    await load();
  }

  Future<void> deleteTransaction(int id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _db.delete(id);
  }
}