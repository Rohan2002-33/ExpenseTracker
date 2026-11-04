class TransactionModel {
  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type;
  final DateTime date;

  /// `id` is left out for new rows so SQLite can auto-increment it.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}