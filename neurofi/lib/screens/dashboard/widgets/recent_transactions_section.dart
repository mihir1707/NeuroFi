import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/transaction_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../router/route_names.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final isLoading    = context.watch<TransactionProvider>().isLoading;
    final currency     = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final recent       = transactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, RouteNames.transactions),
                child: Text(
                  'See all',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            _loadingShimmer()
          else if (recent.isEmpty)
            _emptyState(context)
          else
            Column(
              children: recent
                  .map((t) => _TransactionTile(transaction: t, currency: currency))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _loadingShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin:  const EdgeInsets.only(bottom: 12),
          height:  64,
          decoration: BoxDecoration(
            color:        const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color:        const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: const Color(0x26FFFFFF)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Colors.white.withValues(alpha: 0.3),
            size:  48,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first transaction',
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String           currency;

  const _TransactionTile({required this.transaction, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isIncome   = transaction.isIncome;
    final isTransfer = transaction.isTransfer;
    final color      = isTransfer
        ? Colors.amber
        : isIncome
            ? Colors.green
            : Colors.red;
    final icon = isTransfer
        ? Icons.swap_horiz_rounded
        : isIncome
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded;
    final sign = isIncome ? '+' : isTransfer ? '' : '-';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.transactionDetail,
        arguments: transaction.id,
      ),
      child: Container(
        margin:  const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: const Color(0x26FFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width:  44,
              height: 44,
              decoration: BoxDecoration(
                color:        color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                  child: Text(
                    _categoryEmoji(transaction.displayCategory),
                    style: const TextStyle(fontSize: 20),
                  ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : transaction.displayCategory,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:      Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.toRelative(transaction.transactionDate),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${CurrencyFormatter.format(transaction.amount, currency)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color:      color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  margin:  const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:        color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isTransfer ? 'Transfer' : isIncome ? 'Income' : 'Expense',
                    style: AppTextStyles.labelSmall.copyWith(
                      color:    color,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(icon, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(String category) {
    final map = {
      'food':          '🍔',
      'transport':     '🚗',
      'shopping':      '🛍️',
      'entertainment': '🎬',
      'health':        '💊',
      'education':     '📚',
      'bills':         '📄',
      'salary':        '💼',
      'investment':    '📈',
      'travel':        '✈️',
      'groceries':     '🛒',
      'rent':          '🏠',
      'utilities':     '💡',
      'other':         '💳',
    };
    final key = category.toLowerCase();
    return map[key] ?? map.entries
        .firstWhere(
          (e) => key.contains(e.key),
          orElse: () => const MapEntry('other', '💳'),
        )
        .value;
  }
}
