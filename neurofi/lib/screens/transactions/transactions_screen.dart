import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/transaction_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../router/route_names.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _selectedFilter = 'all';
  final _searchController = TextEditingController();
  bool _showSearch = false;

  final _filters = ['all', 'income', 'expense', 'transfer'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(limit: 50);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filtered(List<TransactionModel> all) {
    var list = all;
    if (_selectedFilter != 'all') {
      list = list.where((t) => t.type == _selectedFilter).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((t) =>
          t.description.toLowerCase().contains(q) ||
          t.displayCategory.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Map<String, List<TransactionModel>> _grouped(List<TransactionModel> txns) {
    final map = <String, List<TransactionModel>>{};
    for (final t in txns) {
      final key = DateFormatter.toDisplay(t.transactionDate);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider   = context.watch<TransactionProvider>();
    final currency   = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final isLoading  = provider.isLoading;
    final filtered   = _filtered(provider.transactions);
    final grouped    = _grouped(filtered);
    final dateKeys   = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterRow(),
            if (_showSearch) _buildSearchBar(),
            Expanded(
              child: isLoading
                  ? _buildShimmer()
                  : filtered.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: () => provider.loadTransactions(limit: 50),
                          color: Colors.white,
                          backgroundColor: const Color(0xFF111111),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                            itemCount: dateKeys.length,
                            itemBuilder: (_, i) {
                              final date   = dateKeys[i];
                              final dayTxns = grouped[date]!;
                              final dayTotal = dayTxns.fold<double>(
                                0,
                                (s, t) => t.isIncome ? s + t.amount : s - t.amount,
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(date,
                                            style: AppTextStyles.labelMedium.copyWith(
                                                color: Colors.white.withValues(alpha: 0.6))),
                                        Text(
                                          CurrencyFormatter.format(dayTotal.abs(), currency,
                                              showSign: true),
                                          style: AppTextStyles.labelMedium.copyWith(
                                            color: dayTotal >= 0
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...dayTxns.map((t) => _TxTile(
                                        t: t,
                                        currency: currency,
                                      )),
                                ],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final bool isPushed = ModalRoute.of(context)?.settings.name == RouteNames.transactions;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isPushed) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              Text('Transactions',
                  style: AppTextStyles.headingLarge.copyWith(color: Colors.white)),
            ],
          ),
          Row(
            children: [
              _iconBtn(Icons.search_rounded,
                  () => setState(() => _showSearch = !_showSearch)),
              const SizedBox(width: 8),
              _iconBtn(Icons.add_rounded,
                  () => Navigator.pushNamed(context, RouteNames.addTransaction)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f        = _filters[i];
          final selected = f == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.white : const Color(0x33FFFFFF),
                ),
              ),
              child: Text(
                f[0].toUpperCase() + f.substring(1),
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? Colors.black : Colors.white.withValues(alpha: 0.6),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.6)),
          filled: true,
          fillColor: const Color(0xFF111111),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() => _searchController.clear()),
                  child: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.6), size: 18))
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x33FFFFFF))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x33FFFFFF))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No transactions found',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 6),
          Text('Try a different filter or add one',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 18),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final TransactionModel t;
  final String currency;
  const _TxTile({required this.t, required this.currency});

  @override
  Widget build(BuildContext context) {
    final color = t.isTransfer ? Colors.amber : t.isIncome ? Colors.green : Colors.red;
    final sign  = t.isIncome ? '+' : t.isTransfer ? '' : '-';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.transactionDetail, arguments: t.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(_emoji(t.displayCategory), style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.description.isNotEmpty ? t.description : t.displayCategory,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(DateFormatter.toRelative(t.transactionDate),
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Text(
              '$sign${CurrencyFormatter.format(t.amount, currency)}',
              style: AppTextStyles.labelMedium.copyWith(
                  color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  String _emoji(String cat) {
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️',
      'entertainment': '🎬', 'health': '💊', 'education': '📚',
      'bills': '📄', 'salary': '💼', 'investment': '📈',
      'travel': '✈️', 'groceries': '🛒', 'rent': '🏠',
      'utilities': '💡', 'transfer': '🔄',
    };
    final k = cat.toLowerCase();
    return map[k] ?? map.entries.firstWhere((e) => k.contains(e.key),
        orElse: () => const MapEntry('', '💳')).value;
  }
}
