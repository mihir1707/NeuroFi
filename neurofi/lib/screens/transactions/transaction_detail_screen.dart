import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/transaction_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactionById(widget.transactionId);
    });
  }

  Future<void> _delete(TransactionModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Transaction',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        content: Text('This action cannot be undone.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<TransactionProvider>().deleteTransaction(t.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t        = context.watch<TransactionProvider>().selectedTransaction;
    final currency = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final isLoading = context.watch<TransactionProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Transaction Detail',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
      ),
      body: isLoading || t == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : _buildBody(t, currency),
    );
  }

  Widget _buildBody(TransactionModel t, String currency) {
    final color = t.isTransfer ? AppColors.amber : t.isIncome ? AppColors.green : AppColors.red;
    final sign  = t.isIncome ? '+' : t.isTransfer ? '' : '-';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.15), AppColors.darkBg1],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _emoji(t.displayCategory),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$sign${CurrencyFormatter.format(t.amount, currency)}',
                        style: AppTextStyles.displayLarge.copyWith(color: color, fontSize: 40),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.description.isNotEmpty ? t.description : t.displayCategory,
                        style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.type.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                              color: color, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _detailCard([
                  _DetailRow(label: 'Category', value: t.displayCategory,
                      icon: Icons.category_outlined),
                  _DetailRow(label: 'Date',
                      value: DateFormatter.toDisplay(t.transactionDate),
                      icon: Icons.calendar_today_outlined),
                  _DetailRow(label: 'Currency', value: t.currency,
                      icon: Icons.currency_exchange_rounded),
                  if (t.notes.isNotEmpty)
                    _DetailRow(label: 'Notes', value: t.notes,
                        icon: Icons.sticky_note_2_outlined),
                  _DetailRow(label: 'Status', value: t.status.toUpperCase(),
                      icon: Icons.check_circle_outline_rounded),
                  if (t.isRecurring)
                    _DetailRow(label: 'Recurring', value: t.recurrenceInterval ?? 'Yes',
                        icon: Icons.repeat_rounded),
                ]),
                if (t.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tags', style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.darkText3)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: t.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.forest.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.forest.withOpacity(0.4)),
                            ),
                            child: Text(tag, style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.sage)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _buildActions(t),
      ],
    );
  }

  Widget _detailCard(List<_DetailRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(e.value.icon, color: AppColors.darkText3, size: 18),
                    const SizedBox(width: 12),
                    Text(e.value.label,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3)),
                    const Spacer(),
                    Text(e.value.value,
                        style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.lightGrey, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, color: AppColors.darkBorder, indent: 46),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions(TransactionModel t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.darkBg0,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _delete(t),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.red.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 18),
                    const SizedBox(width: 6),
                    Text('Delete', style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.red, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _emoji(String cat) {
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️',
      'entertainment': '🎬', 'health': '💊', 'education': '📚',
      'bills': '📄', 'salary': '💼', 'investment': '📈',
      'travel': '✈️', 'groceries': '🛒', 'rent': '🏠',
    };
    final k = cat.toLowerCase();
    return map[k] ?? map.entries.firstWhere(
        (e) => k.contains(e.key), orElse: () => const MapEntry('', '💳')).value;
  }
}

class _DetailRow {
  final String label, value;
  final IconData icon;
  const _DetailRow({required this.label, required this.value, required this.icon});
}
