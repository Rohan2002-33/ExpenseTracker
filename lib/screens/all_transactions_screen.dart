import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../providers/transaction_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  static const List<String> _filters = [
    'All',
    TransactionType.income,
    TransactionType.expense,
  ];

  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final query = _query.trim().toLowerCase();

    final results = provider.transactions.where((t) {
      final matchesType = _filter == 'All' || t.type == _filter;
      final matchesQuery = query.isEmpty ||
          t.title.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: fieldDecoration(
                hint: 'Search by title or category',
                icon: Icons.search_rounded,
              ).copyWith(
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final filter in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _filter == filter,
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _filter == filter
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _filter == filter
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${results.length} ${results.length == 1 ? 'transaction' : 'transactions'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: provider.transactions.isEmpty
                        ? const EmptyState(
                            icon: Icons.receipt_long_rounded,
                            title: 'No transactions yet',
                            message:
                                'Add your first income or expense from the dashboard.',
                          )
                        : const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No results found',
                            message: 'Try a different search or filter.',
                          ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final transaction = results[index];
                      return TransactionTile(
                        transaction: transaction,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TransactionDetailsScreen(
                                transactionId: transaction.id!,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}