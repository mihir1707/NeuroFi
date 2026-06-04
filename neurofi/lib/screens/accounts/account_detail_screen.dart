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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(account?.name ?? 'Account',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading || account == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: () async {
                await acProvider.loadAccountById(widget.accountId);
                txProvider.setFilter(accountId: widget.accountId);
              },
              color: Colors.white, backgroundColor: const Color(0xFF111111),
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
                            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final t     = txns[i];
                        final color = t.isIncome ? Colors.green : Colors.red;
                        final sign  = t.isIncome ? '+' : '-';
                        return Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x33FFFFFF)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
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
                                        color: Colors.white, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis),
                                Text(DateFormatter.toRelative(t.transactionDate),
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
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
    final color = account.balance >= 0 ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x33FFFFFF)),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(child: Text(account.icon, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(account.name,
                    style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                Text(account.typeLabel,
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
              ]),
            ]),
            const SizedBox(height: 20),
            Text('Balance', style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
            Text(CurrencyFormatter.format(account.balance.abs(), currency),
                style: AppTextStyles.displayMedium.copyWith(color: color, fontWeight: FontWeight.w800)),
            if (account.accountNumberLast4.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('•••• •••• •••• ${account.accountNumberLast4}',
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.4))),
            ],
            if (account.institution.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(account.institution,
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.4))),
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
