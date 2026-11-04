import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';
import 'all_transactions_screen.dart';
import 'transaction_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddEditTransactionScreen(),
      ),
    );
  }

  void _openAll(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AllTransactionsScreen(),
      ),
    );
  }

  void _openDetails(BuildContext context, TransactionModel transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailsScreen(
          transactionId: transaction.id!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final recent = provider.recentTransactions;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openAdd(context),
          tooltip: 'Add transaction',
          child: const Icon(Icons.add_rounded, size: 28),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: 2 + (recent.isEmpty ? 1 : recent.length),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _Header(
                      balance: provider.balance,
                      income: provider.totalIncome,
                      expense: provider.totalExpense,
                    );
                  }
                  if (index == 1) {
                    return _SectionTitle(
                      showSeeAll: provider.transactions.isNotEmpty,
                      onSeeAll: () => _openAll(context),
                    );
                  }
                  if (recent.isEmpty) {
                    return const EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No transactions yet',
                      message:
                          'Tap the + button to record your first income or expense.',
                    );
                  }

                  final transaction = recent[index - 2];
                  final isLast = index == recent.length + 1;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 96 : 0),
                    child: TransactionTile(
                      transaction: transaction,
                      onTap: () => _openDetails(context, transaction),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.balance,
    required this.income,
    required this.expense,
  });

  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      kAppName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Fmt.todayLabel(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SummaryCard(
            title: 'Current Balance',
            amount: balance,
            icon: Icons.account_balance_rounded,
            accent: AppColors.primary,
            large: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Income',
                  amount: income,
                  icon: Icons.south_west_rounded,
                  accent: AppColors.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Total Expense',
                  amount: expense,
                  icon: Icons.north_east_rounded,
                  accent: AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.showSeeAll, required this.onSeeAll});

  final bool showSeeAll;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 12, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (showSeeAll)
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }
}