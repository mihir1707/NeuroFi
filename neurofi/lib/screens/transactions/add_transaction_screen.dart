import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/account_model.dart';
import '../../models/category_model.dart';
import '../../core/utils/currency_formatter.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _typeController;

  final _descController = TextEditingController();
  final _notesController = TextEditingController();
  String _amount = '';
  String _selectedType = 'expense';
  AccountModel? _selectedAccount;
  AccountModel? _transferToAccount;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurrenceInterval = 'monthly';

  final _types = ['expense', 'income', 'transfer'];

  @override
  void initState() {
    super.initState();
    _typeController = TabController(length: 3, vsync: this);
    _typeController.addListener(() {
      setState(() => _selectedType = _types[_typeController.index]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onNumpad(String val) {
    setState(() {
      if (val == '⌫') {
        if (_amount.isNotEmpty) _amount = _amount.substring(0, _amount.length - 1);
      } else if (val == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.length < 10) {
        _amount += val;
      }
    });
  }

  double get _parsedAmount => double.tryParse(_amount) ?? 0;

  Color get _typeColor {
    switch (_selectedType) {
      case 'income':   return Colors.green;
      case 'transfer': return Colors.amber;
      default:         return Colors.red;
    }
  }

  Future<void> _submit() async {
    if (_parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')));
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')));
      return;
    }
    final currency = context.read<AuthProvider>().user?.currency ?? 'INR';
    final ok = await context.read<TransactionProvider>().createTransaction(
      accountId:         _selectedAccount!.id,
      type:              _selectedType,
      amount:            _parsedAmount,
      transactionDate:   _selectedDate.toIso8601String(),
      currency:          currency,
      description:       _descController.text.trim(),
      notes:             _notesController.text.trim(),
      categoryId:        _selectedCategory?.id,
      isRecurring:       _isRecurring,
      recurrenceInterval: _isRecurring ? _recurrenceInterval : null,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accounts  = context.watch<AccountProvider>().accounts;
    final categories = context.watch<CategoryProvider>().categories
        .where((c) => _selectedType == 'income'
            ? c.type != 'expense'
            : c.type != 'income')
        .toList();
    final isCreating = context.watch<TransactionProvider>().isCreating;
    final currency   = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final sym        = CurrencyFormatter.symbolFor(currency);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Transaction',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildAmountDisplay(sym),
                  const SizedBox(height: 20),
                  _buildNumpad(),
                  const SizedBox(height: 24),
                  _buildFields(accounts, categories),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildSubmitButton(isCreating),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: TabBar(
        controller: _typeController,
        indicator: BoxDecoration(
          color: _typeColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _typeColor.withValues(alpha: 0.5)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        labelColor: _typeColor,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        tabs: const [
          Tab(text: 'Expense', height: 42),
          Tab(text: 'Income', height: 42),
          Tab(text: 'Transfer', height: 42),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(String sym) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text('Amount', style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 8),
          Text(
            _amount.isEmpty ? '${sym}0' : '$sym$_amount',
            style: AppTextStyles.displayLarge.copyWith(
              color: _amount.isEmpty ? Colors.white.withValues(alpha: 0.6) : _typeColor,
              fontSize: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = ['1','2','3','4','5','6','7','8','9','.','0','⌫'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing:  10,
      ),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        return GestureDetector(
          onTap: () => _onNumpad(key),
          child: Container(
            decoration: BoxDecoration(
              color: key == '⌫' ? const Color(0xFF222222) : const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Center(
              child: key == '⌫'
                  ? Icon(Icons.backspace_outlined, color: Colors.white.withValues(alpha: 0.6), size: 18)
                  : Text(key, style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFields(List<AccountModel> accounts, List<CategoryModel> categories) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF111111),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x33FFFFFF))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x33FFFFFF))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5)),
      labelStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
      hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
    );

    return Column(
      children: [
        DropdownButtonFormField<AccountModel>(
          initialValue: _selectedAccount,
          decoration: inputDecoration.copyWith(labelText: 'From Account'),
          dropdownColor: const Color(0xFF111111),
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          items: accounts.map((a) => DropdownMenuItem(
            value: a,
            child: Row(children: [
              Text(a.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(a.name),
            ]),
          )).toList(),
          onChanged: (v) => setState(() => _selectedAccount = v),
        ),
        const SizedBox(height: 12),
        if (_selectedType == 'transfer') ...[
          DropdownButtonFormField<AccountModel>(
            initialValue: _transferToAccount,
            decoration: inputDecoration.copyWith(labelText: 'To Account'),
            dropdownColor: const Color(0xFF111111),
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            items: accounts
                .where((a) => a.id != _selectedAccount?.id)
                .map((a) => DropdownMenuItem(
                  value: a,
                  child: Row(children: [
                    Text(a.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(a.name),
                  ]),
                )).toList(),
            onChanged: (v) => setState(() => _transferToAccount = v),
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedType != 'transfer') ...[
          DropdownButtonFormField<CategoryModel>(
            initialValue: _selectedCategory,
            decoration: inputDecoration.copyWith(labelText: 'Category (optional)'),
            dropdownColor: const Color(0xFF111111),
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            items: categories.map((c) => DropdownMenuItem(
              value: c,
              child: Row(children: [
                Text(c.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(c.name),
              ]),
            )).toList(),
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _descController,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          decoration: inputDecoration.copyWith(
            labelText: 'Description',
            prefixIcon: Icon(Icons.notes_rounded, color: Colors.white.withValues(alpha: 0.6), size: 18),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: Colors.white),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.white.withValues(alpha: 0.6), size: 18),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          decoration: inputDecoration.copyWith(
            labelText: 'Notes (optional)',
            prefixIcon: Icon(Icons.sticky_note_2_outlined, color: Colors.white.withValues(alpha: 0.6), size: 18),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Row(
            children: [
              Icon(Icons.repeat_rounded, color: Colors.white.withValues(alpha: 0.6), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Recurring',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ),
              Switch(
                value: _isRecurring,
                activeThumbColor: Colors.white,
                onChanged: (v) => setState(() => _isRecurring = v),
              ),
            ],
          ),
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _recurrenceInterval,
            decoration: inputDecoration.copyWith(labelText: 'Repeats'),
            dropdownColor: const Color(0xFF111111),
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            items: ['daily','weekly','monthly','yearly']
                .map((v) => DropdownMenuItem(value: v, child: Text(v.toUpperCase())))
                .toList(),
            onChanged: (v) => setState(() => _recurrenceInterval = v ?? 'monthly'),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(bool isCreating) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
      ),
      child: GestureDetector(
        onTap: isCreating ? null : _submit,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: isCreating ? const Color(0xFF222222) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isCreating
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2))
                : Text('Save Transaction',
                    style: AppTextStyles.buttonText.copyWith(color: Colors.black)),
          ),
        ),
      ),
    );
  }
}
