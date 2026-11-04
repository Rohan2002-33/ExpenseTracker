import 'package:flutter/material.dart';

const String kAppName = 'Expense Tracker';

/// Change to '\$' or 'Tk' if the Taka sign does not render on your device.
const String kCurrencySymbol = '৳';

class TransactionType {
  TransactionType._();

  static const String income = 'Income';
  static const String expense = 'Expense';
}

const List<String> kCategories = [
  'Food & Dining',
  'Transport',
  'Shopping',
  'Bills & Utilities',
  'Health',
  'Entertainment',
  'Education',
  'Salary',
  'Freelance',
  'Investment',
  'Gift',
  'Other',
];

IconData categoryIcon(String category) {
  switch (category) {
    case 'Food & Dining':
      return Icons.restaurant_rounded;
    case 'Transport':
      return Icons.directions_bus_rounded;
    case 'Shopping':
      return Icons.shopping_bag_rounded;
    case 'Bills & Utilities':
      return Icons.receipt_long_rounded;
    case 'Health':
      return Icons.medical_services_rounded;
    case 'Entertainment':
      return Icons.movie_rounded;
    case 'Education':
      return Icons.school_rounded;
    case 'Salary':
      return Icons.payments_rounded;
    case 'Freelance':
      return Icons.laptop_mac_rounded;
    case 'Investment':
      return Icons.trending_up_rounded;
    case 'Gift':
      return Icons.card_giftcard_rounded;
    default:
      return Icons.more_horiz_rounded;
  }
}