import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/account_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class AccountDetailScreen extends StatefulWidget {
  final String accountId;
  const AccountDetailScreen({super.key, required this.accountId});
  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccountById(widget.accountId);
      context.read<TransactionProvider>().setFilter(accountId: widget.accountId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final acProvider = context.watch<AccountProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final account    = acProvider.selectedAccount;
    final txns       = txProvider.transactions;
    final currency   = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final isLoading  = acProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(account?.name ?? 'Account',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
      ),
      body: isLoading || account == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : RefreshIndicator(
              onRefresh: () async {
                await acProvider.loadAccountById(widget.accountId);
                txProvider.setFilter(accountId: widget.accountId);
              },
              color: AppColors.green, backgroundColor: AppColors.darkBg1,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeroCard(account, currency)),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  if (txns.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Text('Recent Transactions',
                            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final t     = txns[i];
                        final color = t.isIncome ? AppColors.green : AppColors.red;
                        final sign  = t.isIncome ? '+' : '-';
                        return Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.darkBg1,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text(
                                t.displayCategory.isNotEmpty ? _emoji(t.displayCategory) : '💳',
                                style: const TextStyle(fontSize: 18),
                              )),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(t.description.isNotEmpty ? t.description : t.displayCategory,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.lightGrey, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis),
                                Text(DateFormatter.toRelative(t.transactionDate),
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
                              ]),
                            ),
                            Text('$sign${CurrencyFormatter.format(t.amount, currency)}',
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: color, fontWeight: FontWeight.w700)),
                          ]),
                        );
                      },
                      childCount: txns.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard(AccountModel account, String currency) {
    final color = account.balance >= 0 ? AppColors.green : AppColors.red;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.darkForest, AppColors.forest],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
              color: AppColors.forest.withOpacity(0.3),
              blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(child: Text(account.icon, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(account.name,
                    style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
                Text(account.typeLabel,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.sage)),
              ]),
            ]),
            const SizedBox(height: 20),
            Text('Balance', style: AppTextStyles.labelSmall.copyWith(color: AppColors.sage.withOpacity(0.7))),
            Text(CurrencyFormatter.format(account.balance.abs(), currency),
                style: AppTextStyles.displayMedium.copyWith(color: color, fontWeight: FontWeight.w800)),
            if (account.accountNumberLast4.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('•••• •••• •••• ${account.accountNumberLast4}',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.sage.withOpacity(0.6))),
            ],
            if (account.institution.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(account.institution,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.sage.withOpacity(0.5))),
            ],
          ],
        ),
      ),
    );
  }

  String _emoji(String cat) {
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️',
      'entertainment': '🎬', 'health': '💊', 'education': '📚',
      'bills': '📄', 'salary': '💼', 'investment': '📈', 'groceries': '🛒',
    };
    final k = cat.toLowerCase();
    return map[k] ?? map.entries.firstWhere(
        (e) => k.contains(e.key), orElse: () => const MapEntry('', '💳')).value;
  }
}
