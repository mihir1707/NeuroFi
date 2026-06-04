import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'dart:math' as math;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final _tabs = ['Overview', 'Income', 'Expense'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(limit: 100);
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final transactions = context.watch<TransactionProvider>().transactions;
    final accounts     = context.watch<AccountProvider>().accounts;
    final currency     = context.watch<AuthProvider>().user?.currency ?? 'INR';

    final now   = DateTime.now();
    final month = transactions.where((t) {
      final d = DateTime.tryParse(t.transactionDate) ?? now;
      return d.month == now.month && d.year == now.year;
    }).toList();

    final totalIncome  = month.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final totalExpense = month.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
    final netSavings   = totalIncome - totalExpense;
    final savingsRate  = totalIncome > 0 ? (netSavings / totalIncome * 100).clamp(0.0, 100.0) : 0.0;

    final Map<String, double> catTotals = {};
    for (final t in month.where((t) => t.isExpense)) {
      final c = t.displayCategory;
      catTotals[c] = (catTotals[c] ?? 0) + t.amount;
    }
    final topCats = (catTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(6)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverview(
                    currency: currency,
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                    netSavings: netSavings,
                    savingsRate: savingsRate,
                    topCats: topCats,
                    totalBalance: accounts.fold<double>(0, (s, a) => s + a.balance),
                    transactions: transactions,
                  ),
                  _buildIncomeExpenseTab(
                      currency: currency,
                      transactions: transactions,
                      type: 'income'),
                  _buildIncomeExpenseTab(
                      currency: currency,
                      transactions: transactions,
                      type: 'expense'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Analytics',
              style: AppTextStyles.headingLarge.copyWith(color: AppColors.lightGrey)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkBg1,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Text('This Month',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.sage)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkBg1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelMedium,
          labelColor: AppColors.lightGrey,
          unselectedLabelColor: AppColors.darkText3,
          tabs: _tabs.map((t) => Tab(text: t, height: 38)).toList(),
        ),
      ),
    );
  }

  Widget _buildOverview({
    required String currency,
    required double totalIncome,
    required double totalExpense,
    required double netSavings,
    required double savingsRate,
    required List topCats,
    required double totalBalance,
    required List transactions,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _summaryRow(currency, totalIncome, totalExpense, netSavings),
          const SizedBox(height: 20),
          _savingsRateCard(savingsRate, currency, netSavings),
          const SizedBox(height: 20),
          _categoryBreakdown(topCats, totalExpense, currency),
          const SizedBox(height: 20),
          _monthlyBars(transactions, currency),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _summaryRow(String currency, double income, double expense, double net) {
    return Row(
      children: [
        Expanded(child: _miniCard('Income', income, AppColors.green, Icons.arrow_downward_rounded, currency)),
        const SizedBox(width: 10),
        Expanded(child: _miniCard('Expense', expense, AppColors.red, Icons.arrow_upward_rounded, currency)),
        const SizedBox(width: 10),
        Expanded(child: _miniCard('Saved', net, net >= 0 ? AppColors.amber : AppColors.red,
            net >= 0 ? Icons.savings_outlined : Icons.trending_down_rounded, currency)),
      ],
    );
  }

  Widget _miniCard(String label, double val, Color color, IconData icon, String currency) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkBg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(CurrencyFormatter.formatCompact(val.abs(), currency),
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.lightGrey, fontWeight: FontWeight.w700)),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
        ],
      ),
    );
  }

  Widget _savingsRateCard(double rate, String currency, double net) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Savings Rate',
                  style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
              Text('${rate.toStringAsFixed(1)}%',
                  style: AppTextStyles.headingSmall.copyWith(
                      color: rate >= 20 ? AppColors.green : rate >= 10 ? AppColors.amber : AppColors.red,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 10,
              backgroundColor: AppColors.darkBg2,
              valueColor: AlwaysStoppedAnimation(
                  rate >= 20 ? AppColors.green : rate >= 10 ? AppColors.amber : AppColors.red),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rate >= 20
                ? '🎉 Great savings habit!'
                : rate >= 10
                    ? '👍 Good, aim for 20%+'
                    : '⚠️ Try to save more this month',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText2),
          ),
        ],
      ),
    );
  }

  Widget _categoryBreakdown(List topCats, double total, String currency) {
    if (topCats.isEmpty) return const SizedBox.shrink();
    const colors = [AppColors.green, AppColors.amber, AppColors.salmon,
                    AppColors.sage, AppColors.peach, AppColors.pink];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Spending Categories',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
          const SizedBox(height: 16),
          ...topCats.asMap().entries.map((e) {
            final color = colors[e.key % colors.length];
            final pct   = total > 0 ? e.value.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.value.key,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGrey)),
                      Text(CurrencyFormatter.format(e.value.value, currency),
                          style: AppTextStyles.labelMedium.copyWith(
                              color: color, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.darkBg2,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _monthlyBars(List transactions, String currency) {
    final now  = DateTime.now();
    final data = List.generate(6, (i) {
      final m    = DateTime(now.year, now.month - (5 - i));
      final txns = transactions.where((t) {
        final d = DateTime.tryParse(t.transactionDate) ?? now;
        return d.month == m.month && d.year == m.year;
      }).toList();
      return {
        'month':   ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m.month - 1],
        'income':  txns.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount),
        'expense': txns.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount),
      };
    });

    final maxVal = data.expand((d) => [d['income'] as double, d['expense'] as double])
        .fold<double>(1, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('6-Month Trend',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final ih = maxVal > 0 ? ((d['income'] as double) / maxVal) * 90 : 0.0;
                final eh = maxVal > 0 ? ((d['expense'] as double) / maxVal) * 90 : 0.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: 8,
                            height: ih.clamp(4, 90),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.8),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: 8,
                            height: eh.clamp(4, 90),
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.8),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(d['month'] as String,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.darkText3, fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseTab({
    required String currency,
    required List transactions,
    required String type,
  }) {
    final filtered = transactions.where((t) => t.type == type).toList();
    final total    = filtered.fold<double>(0, (s, t) => s + t.amount);
    final color    = type == 'income' ? AppColors.green : AppColors.red;

    final Map<String, double> cats = {};
    for (final t in filtered) {
      final c = t.displayCategory;
      cats[c] = (cats[c] ?? 0) + t.amount;
    }
    final sorted = (cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(8).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), AppColors.darkBg1]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(type == 'income' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: color, size: 28),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total ${type[0].toUpperCase()}${type.substring(1)}',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText2)),
                    Text(CurrencyFormatter.format(total, currency),
                        style: AppTextStyles.displayMedium.copyWith(
                            color: color, fontWeight: FontWeight.w800)),
                    Text('${filtered.length} transactions',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
                  ],
                ),
              ],
            ),
          ),
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkBg1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By Category',
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
                  const SizedBox(height: 14),
                  ...sorted.map((e) {
                    final pct = total > 0 ? e.value / total : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 42, height: 42,
                            child: CustomPaint(
                              painter: _RingPainter(pct, color),
                              child: Center(
                                child: Text('${(pct * 100).toStringAsFixed(0)}%',
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.lightGrey, fontSize: 8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(e.key,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.lightGrey)),
                          ),
                          Text(CurrencyFormatter.format(e.value, currency),
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: color, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color  color;
  const _RingPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 4;
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = AppColors.darkBg2..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, value.clamp(0, 1) * 2 * math.pi, false,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}
