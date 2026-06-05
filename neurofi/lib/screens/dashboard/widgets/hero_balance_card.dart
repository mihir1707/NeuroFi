import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class HeroBalanceCard extends StatefulWidget {
  const HeroBalanceCard({super.key});

  @override
  State<HeroBalanceCard> createState() => _HeroBalanceCardState();
}

class _HeroBalanceCardState extends State<HeroBalanceCard>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final user            = context.watch<AuthProvider>().user;
    final currency        = user?.currency ?? 'INR';
    final totalBalance    = accountProvider.totalBalance;
    final accounts        = accountProvider.accounts;

    final monthlyReport   = context.watch<ReportProvider>().monthlyReport;

    final totalIncome  = monthlyReport?.totalIncome ?? 0.0;
    final totalExpense = monthlyReport?.totalExpenses ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color:        Colors.black,
          borderRadius: BorderRadius.circular(24),
          border:       Border.all(color: const Color(0x26FFFFFF)),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset:     const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                        child: Icon(
                          _balanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size:  20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _balanceVisible
                      ? Text(
                          CurrencyFormatter.format(totalBalance, currency),
                          style: AppTextStyles.displayLarge.copyWith(
                            color:      Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize:   36,
                          ),
                        )
                      : Text(
                          '••••••',
                          style: AppTextStyles.displayLarge.copyWith(
                            color:    Colors.white,
                            fontSize: 36,
                          ),
                        ),
                  const SizedBox(height: 6),
                  Text(
                    '${accounts.length} account${accounts.length != 1 ? 's' : ''}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _statChip(
                          label:  'Income',
                          value:  CurrencyFormatter.format(totalIncome, currency),
                          icon:   Icons.arrow_downward_rounded,
                          color:  Colors.green,
                          visible: _balanceVisible,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statChip(
                          label:  'Expense',
                          value:  CurrencyFormatter.format(totalExpense, currency),
                          icon:   Icons.arrow_upward_rounded,
                          color:  AppColors.red,
                          visible: _balanceVisible,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip({
    required String  label,
    required String  value,
    required IconData icon,
    required Color   color,
    required bool    visible,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width:  28,
            height: 28,
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  visible ? value : '••••',
                  style: AppTextStyles.labelMedium.copyWith(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
