import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.accent,
    this.large = false,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color accent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final amountColor = large
        ? (amount < 0 ? AppColors.expense : AppColors.textPrimary)
        : accent;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(large ? 20 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(large ? 22 : 18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: large ? 14 : 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Fmt.money(amount),
              style: TextStyle(
                fontSize: large ? 30 : 18,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}