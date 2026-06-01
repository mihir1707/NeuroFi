import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/budget_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../router/route_names.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});
  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider  = context.watch<BudgetProvider>();
    final currency  = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final budgets   = provider.budgets;
    final isLoading = provider.isLoading;

    final totalBudgeted = budgets.fold<double>(0, (s, b) => s + b.amount);
    final totalSpent    = budgets.fold<double>(0, (s, b) => s + b.spent);
    final overallPct    = totalBudgeted > 0 ? (totalSpent / totalBudgeted * 100).clamp(0.0, 100.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadBudgets(),
          color: AppColors.green,
          backgroundColor: AppColors.darkBg1,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (budgets.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSummaryCard(currency, totalBudgeted, totalSpent, overallPct)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text('Active Budgets',
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (isLoading)
                SliverList(delegate: SliverChildBuilderDelegate(
                  (_, __) => _shimmer(), childCount: 3))
              else if (budgets.isEmpty)
                SliverToBoxAdapter(child: _emptyState(context))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _BudgetCard(budget: budgets[i], currency: currency),
                    childCount: budgets.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Budgets',
              style: AppTextStyles.headingLarge.copyWith(color: AppColors.lightGrey)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.addBudget),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.add_rounded, color: AppColors.lightGrey, size: 16),
                const SizedBox(width: 4),
                Text('Add', style: AppTextStyles.labelMedium.copyWith(color: AppColors.lightGrey)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String currency, double total, double spent, double pct) {
    final color = pct >= 100 ? AppColors.red : pct >= 80 ? AppColors.amber : AppColors.green;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkForest, AppColors.darkBg1],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.forest.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Overview',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.sage)),
                Text('${pct.toStringAsFixed(0)}%',
                    style: AppTextStyles.headingSmall.copyWith(
                        color: color, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 10,
                backgroundColor: AppColors.darkBg2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _amtLabel('Spent', spent, currency, AppColors.red),
                _amtLabel('Budgeted', total, currency, AppColors.sage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amtLabel(String label, double val, String currency, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
        Text(CurrencyFormatter.formatCompact(val, currency),
            style: AppTextStyles.titleMedium.copyWith(color: color)),
      ],
    );
  }

  Widget _shimmer() => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    height: 90,
    decoration: BoxDecoration(
      color: AppColors.darkBg1, borderRadius: BorderRadius.circular(16)),
  );

  Widget _emptyState(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(children: [
      const Text('📊', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text('No budgets yet',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText2)),
      const SizedBox(height: 6),
      Text('Set spending limits to stay on track',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, RouteNames.addBudget),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Create Budget',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.lightGrey)),
        ),
      ),
    ]),
  );
}

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final String currency;
  const _BudgetCard({required this.budget, required this.currency});

  @override
  Widget build(BuildContext context) {
    final pct   = budget.percentUsed;
    final color = budget.isExceeded ? AppColors.red : budget.isWarning ? AppColors.amber : AppColors.green;
    final catName = budget.category?.name ?? 'Budget';
    final catIcon = budget.category?.icon ?? '📊';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.budgetDetail, arguments: budget.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: budget.isExceeded
              ? AppColors.red.withOpacity(0.3) : AppColors.darkBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(catIcon, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(catName,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lightGrey, fontWeight: FontWeight.w600)),
                      Text(budget.period.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${CurrencyFormatter.formatCompact(budget.spent, currency)} / ${CurrencyFormatter.formatCompact(budget.amount, currency)}',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.lightGrey, fontWeight: FontWeight.w700),
                    ),
                    Text('${pct.toStringAsFixed(0)}% used',
                        style: AppTextStyles.labelSmall.copyWith(color: color)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 6,
                backgroundColor: AppColors.darkBg2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            if (budget.isExceeded) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 14),
                const SizedBox(width: 4),
                Text('Exceeded by ${CurrencyFormatter.formatCompact((budget.spent - budget.amount), currency)}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.red)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
