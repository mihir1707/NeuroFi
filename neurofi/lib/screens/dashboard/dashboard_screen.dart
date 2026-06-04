import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../router/route_names.dart';
import 'widgets/hero_balance_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/recent_transactions_section.dart';
import 'widgets/income_expense_chart.dart';
import 'widgets/spending_donut_chart.dart';
import 'widgets/ai_insight_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await Future.wait([
      context.read<AccountProvider>().loadAccounts(),
      context.read<TransactionProvider>().loadTransactions(limit: 5),
      context.read<BudgetProvider>().loadActiveBudgets(),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      body: RefreshIndicator(
        onRefresh:   _onRefresh,
        color:       AppColors.green,
        backgroundColor: AppColors.darkBg1,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(user?.name ?? 'User'),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverToBoxAdapter(child: HeroBalanceCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverToBoxAdapter(child: QuickStatsRow()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(child: IncomeExpenseChart()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(child: SpendingDonutChart()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(child: AiInsightSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(child: RecentTransactionsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return SliverAppBar(
      backgroundColor:    Colors.black,
      surfaceTintColor:   Colors.transparent,
      elevation:          0,
      floating:           true,
      snap:               true,
      pinned:             false,
      expandedHeight:     80,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$greeting 👋',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name.split(' ').first,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _iconButton(
                      icon:    Icons.smart_toy_outlined,
                      onTap:   () => Navigator.pushNamed(
                        context, RouteNames.aiChat,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _iconButton(
                      icon:  Icons.notifications_outlined,
                      onTap: () => Navigator.pushNamed(
                        context, RouteNames.notifications,
                      ),
                      badge: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  40,
        height: 40,
        decoration: BoxDecoration(
          color:        const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (badge)
              Positioned(
                top:   8,
                right: 8,
                child: Container(
                  width:  7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _avatarButton(String name) {
    final initials = name.trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.profile),
      child: Container(
        width:  40,
        height: 40,
        decoration: BoxDecoration(
          color:        const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Center(
          child: Text(
            initials,
            style: AppTextStyles.labelMedium.copyWith(
              color:      Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
