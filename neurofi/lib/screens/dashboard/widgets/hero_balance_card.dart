import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/auth_provider.dart';
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
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmer = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
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

    final totalIncome  = accounts.fold<double>(0, (s, a) => s + (a.balance > 0 ? a.balance : 0));
    final totalExpense = accounts.fold<double>(0, (s, a) => s + (a.balance < 0 ? a.balance.abs() : 0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: [AppColors.darkForest, AppColors.forest, AppColors.darkBg1],
            stops:  [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.forest.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color:      AppColors.forest.withOpacity(0.3),
              blurRadius: 30,
              offset:     const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top:   -30,
              right: -30,
              child: Container(
                width:  140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left:   -20,
              child: Container(
                width:  100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sage.withOpacity(0.06),
                ),
              ),
            ),
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
                          color: AppColors.sage.withOpacity(0.8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                        child: Icon(
                          _balanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.sage.withOpacity(0.7),
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
                            color:      AppColors.lightGrey,
                            fontWeight: FontWeight.w800,
                            fontSize:   36,
                          ),
                        )
                      : Text(
                          '••••••',
                          style: AppTextStyles.displayLarge.copyWith(
                            color:    AppColors.lightGrey,
                            fontSize: 36,
                          ),
                        ),
                  const SizedBox(height: 6),
                  Text(
                    '${accounts.length} account${accounts.length != 1 ? 's' : ''}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.sage.withOpacity(0.6),
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
                          color:  AppColors.green,
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
        color:        Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width:  28,
            height: 28,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.15),
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
                    color: AppColors.darkText2,
                  ),
                ),
                Text(
                  visible ? value : '••••',
                  style: AppTextStyles.labelMedium.copyWith(
                    color:      AppColors.lightGrey,
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
