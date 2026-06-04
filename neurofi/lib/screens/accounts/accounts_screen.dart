import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/account_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../router/route_names.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider  = context.watch<AccountProvider>();
    final currency  = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final accounts  = provider.accounts;
    final isLoading = provider.isLoading;
    final total     = provider.totalBalance;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.loadAccounts(),
                color: Colors.white,
                backgroundColor: const Color(0xFF111111),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _TotalBalanceCard(total: total, currency: currency),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('My Accounts',
                            style: AppTextStyles.headingSmall.copyWith(
                                color: Colors.white)),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    if (isLoading)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, _) => _shimmerCard(),
                          childCount: 3,
                        ),
                      )
                    else if (accounts.isEmpty)
                      SliverToBoxAdapter(child: _emptyState(context))
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _AccountCard(
                            account: accounts[i],
                            currency: currency,
                          ),
                          childCount: accounts.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          ],
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
          Text('Accounts',
              style: AppTextStyles.headingLarge.copyWith(color: Colors.white)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.addAccount),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, color: Colors.black, size: 16),
                  const SizedBox(width: 4),
                  Text('Add', style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('🏦', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No accounts yet',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 6),
          Text('Add your bank, wallet or card to get started',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.4)),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.addAccount),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Add Account',
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final double total;
  final String currency;
  const _TotalBalanceCard({required this.total, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x33FFFFFF)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Net Worth',
                style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.6))),
            const SizedBox(height: 8),
            Text(CurrencyFormatter.format(total, currency),
                style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 32)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  total >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: total >= 0 ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  total >= 0 ? 'Positive balance' : 'Negative balance',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: total >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final String currency;
  const _AccountCard({required this.account, required this.currency});

  static const _typeIcons = {
    'bank': Icons.account_balance_rounded,
    'cash': Icons.payments_rounded,
    'credit_card': Icons.credit_card_rounded,
    'debit_card': Icons.credit_card_outlined,
    'wallet': Icons.account_balance_wallet_rounded,
    'investment': Icons.trending_up_rounded,
    'loan': Icons.money_off_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final icon  = _typeIcons[account.type] ?? Icons.account_balance_rounded;
    final color = account.balance >= 0 ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.accountDetail,
          arguments: account.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: account.icon.isNotEmpty
                    ? Text(account.icon, style: const TextStyle(fontSize: 22))
                    : Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(
                    account.type.replaceAll('_', ' ').toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(account.balance.abs(), currency),
                  style: AppTextStyles.labelMedium.copyWith(
                      color: color, fontWeight: FontWeight.w700),
                ),
                if (account.balance < 0)
                  Text('debt', style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.red, fontSize: 9)),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.4), size: 18),
          ],
        ),
      ),
    );
  }
}
