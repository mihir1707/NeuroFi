import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/category_model.dart';
import '../../core/utils/currency_formatter.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});
  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _amountController = TextEditingController();
  CategoryModel? _selectedCategory;
  String _period = 'monthly';
  double _alertThreshold = 80;
  DateTime _startDate = DateTime.now();

  final _periods = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  InputDecoration get _inputDec => InputDecoration(
    filled: true,
    fillColor: AppColors.darkBg1,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
  );

  Future<void> _submit() async {
    if (_selectedCategory == null || _amountController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;
    final currency = context.read<AuthProvider>().user?.currency ?? 'INR';
    final ok = await context.read<BudgetProvider>().createBudget(
      categoryId:     _selectedCategory!.id,
      amount:         amount,
      currency:       currency,
      period:         _period,
      alertThreshold: _alertThreshold.toInt(),
      startDate:      '${_startDate.year}-${_startDate.month.toString().padLeft(2,'0')}-${_startDate.day.toString().padLeft(2,'0')}',
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories
        .where((c) => c.type != 'income').toList();
    final isLoading  = context.watch<BudgetProvider>().isLoading;
    final currency   = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final sym        = CurrencyFormatter.symbolFor(currency);

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Budget',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    decoration: _inputDec.copyWith(labelText: 'Category'),
                    dropdownColor: AppColors.darkBg1,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
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
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _inputDec.copyWith(
                      labelText: 'Budget Amount',
                      prefixText: '$sym ',
                      prefixStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.sage),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Period', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  Row(
                    children: _periods.map((p) {
                      final selected = p == _period;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _period = p),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(colors: [AppColors.forest, AppColors.green])
                                  : null,
                              color: selected ? null : AppColors.darkBg1,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: selected ? AppColors.green : AppColors.darkBorder),
                            ),
                            child: Center(
                              child: Text(
                                p[0].toUpperCase() + p.substring(1),
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: selected ? AppColors.lightGrey : AppColors.darkText2),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Alert at ${_alertThreshold.toInt()}%',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.green,
                      inactiveTrackColor: AppColors.darkBg2,
                      thumbColor: AppColors.green,
                      overlayColor: AppColors.green.withOpacity(0.15),
                    ),
                    child: Slider(
                      value: _alertThreshold,
                      min: 50, max: 100, divisions: 10,
                      onChanged: (v) => setState(() => _alertThreshold = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(primary: AppColors.green)),
                          child: child!,
                        ),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkBg1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.darkText3, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            'Start: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: GestureDetector(
              onTap: isLoading ? null : _submit,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: AppColors.lightGrey, strokeWidth: 2))
                      : Text('Create Budget',
                          style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
