import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class IncomeExpenseChart extends StatelessWidget {
  const IncomeExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final currency     = context.watch<AuthProvider>().user?.currency ?? 'INR';

    final now       = DateTime.now();
    final last6     = List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i));
      return month;
    });

    final monthlyData = last6.map((month) {
      final txns = transactions.where((t) {
        final d = DateTime.tryParse(t.transactionDate) ?? now;
        return d.month == month.month && d.year == month.year;
      }).toList();

      final income  = txns.where((t) => t.isIncome)
          .fold<double>(0, (s, t) => s + t.amount);
      final expense = txns.where((t) => t.isExpense)
          .fold<double>(0, (s, t) => s + t.amount);

      return _MonthData(
        month:   _shortMonth(month.month),
        income:  income,
        expense: expense,
      );
    }).toList();

    final maxVal = monthlyData
        .expand((m) => [m.income, m.expense])
        .fold<double>(1, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding:     const EdgeInsets.all(20),
        decoration:  BoxDecoration(
          color:        AppColors.darkBg1,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Income vs Expense',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.lightGrey,
                  ),
                ),
                Row(
                  children: [
                    _legend(AppColors.green, 'Income'),
                    const SizedBox(width: 12),
                    _legend(AppColors.red, 'Expense'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthlyData.map((data) {
                  return Expanded(
                    child: _BarGroup(data: data, maxVal: maxVal),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width:  10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3),
        ),
      ],
    );
  }

  String _shortMonth(int month) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[month - 1];
  }
}

class _BarGroup extends StatelessWidget {
  final _MonthData data;
  final double     maxVal;

  const _BarGroup({required this.data, required this.maxVal});

  @override
  Widget build(BuildContext context) {
    final incomeH  = maxVal > 0 ? (data.income  / maxVal) * 110 : 0.0;
    final expenseH = maxVal > 0 ? (data.expense / maxVal) * 110 : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(incomeH,  AppColors.green),
            const SizedBox(width: 3),
            _bar(expenseH, AppColors.red),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          data.month,
          style: AppTextStyles.labelSmall.copyWith(
            color:    AppColors.darkText3,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _bar(double height, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve:    Curves.easeOut,
      width:    10,
      height:   height.clamp(4, 110),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class _MonthData {
  final String month;
  final double income;
  final double expense;
  const _MonthData({required this.month, required this.income, required this.expense});
}
