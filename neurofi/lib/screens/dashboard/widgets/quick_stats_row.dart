import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/account_provider.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final budgets      = context.watch<BudgetProvider>().budgets;
    final accounts     = context.watch<AccountProvider>().accounts;

    final now       = DateTime.now();
    final monthTxns = transactions.where((t) {
      final date = DateTime.tryParse(t.transactionDate) ?? DateTime.now();
      return date.month == now.month && date.year == now.year;
    }).toList();

    final monthIncome  = monthTxns
        .where((t) => t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final monthExpense = monthTxns
        .where((t) => t.isExpense)
        .fold<double>(0, (s, t) => s + t.amount);
    final activeBudgets   = budgets.where((b) => b.isActive).length;
    final exceededBudgets = budgets.where((b) => b.isExceeded).length;

    final stats = [
      _Stat(
        icon:  Icons.trending_up_rounded,
        label: 'This Month',
        value: '${monthTxns.length} txns',
        color: AppColors.sage,
      ),
      _Stat(
        icon:  Icons.savings_outlined,
        label: 'Saved',
        value: monthIncome > monthExpense
            ? '+${(monthIncome - monthExpense).toStringAsFixed(0)}'
            : '0',
        color: AppColors.green,
      ),
      _Stat(
        icon:  Icons.pie_chart_outline_rounded,
        label: 'Budgets',
        value: '$activeBudgets active',
        color: exceededBudgets > 0 ? AppColors.red : AppColors.amber,
      ),
      _Stat(
        icon:  Icons.account_balance_outlined,
        label: 'Accounts',
        value: '${accounts.length} linked',
        color: AppColors.peach,
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.symmetric(horizontal: 20),
        itemCount:       stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _StatCard(stat: stats[i]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        AppColors.darkBg1,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width:  32,
            height: 32,
            decoration: BoxDecoration(
              color:        stat.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: AppTextStyles.labelMedium.copyWith(
                  color:      AppColors.lightGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                stat.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.darkText3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
