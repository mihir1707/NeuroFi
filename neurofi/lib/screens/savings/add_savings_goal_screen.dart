import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/savings_provider.dart';
import '../../providers/auth_provider.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  const AddSavingsGoalScreen({super.key});
  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _nameController   = TextEditingController();
  final _descController   = TextEditingController();
  final _amountController = TextEditingController();
  String _icon      = '🎯';
  DateTime? _deadline;

  static const _emojis = [
    '🎯','🏠','✈️','🚗','💍','🎓','📱','💻',
    '🏖️','💰','🎮','👶','🏋️','🌿','🎨','🎸',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  InputDecoration get _dec => InputDecoration(
    filled: true, fillColor: AppColors.darkBg1,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
  );

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _amountController.text.isEmpty) return;
    final amount   = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;
    final ok = await context.read<SavingsProvider>().createGoal(
      name:         _nameController.text.trim(),
      targetAmount: amount,
      currency:     context.read<AuthProvider>().user?.currency ?? 'INR',
      description:  _descController.text.trim(),
      targetDate:   _deadline?.toIso8601String(),
      icon:         _icon,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<SavingsProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Savings Goal',
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
                  Center(
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.forest.withValues(alpha: 0.5), width: 2),
                      ),
                      child: Center(child: Text(_icon, style: const TextStyle(fontSize: 32))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(labelText: 'Goal Name (e.g. Emergency Fund)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(labelText: 'Target Amount'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 16),
                  Text('Goal Icon', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _emojis.length,
                    itemBuilder: (_, i) {
                      final sel = _emojis[i] == _icon;
                      return GestureDetector(
                        onTap: () => setState(() => _icon = _emojis[i]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: sel ? AppColors.forest.withValues(alpha: 0.3) : AppColors.darkBg1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? AppColors.green : AppColors.darkBorder),
                          ),
                          child: Center(child: Text(_emojis[i], style: const TextStyle(fontSize: 20))),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(primary: AppColors.green)),
                          child: child!,
                        ),
                      );
                      if (picked != null) setState(() => _deadline = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkBg1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(children: [
                        const Icon(Icons.flag_outlined, color: AppColors.darkText3, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          _deadline == null ? 'Set Deadline (optional)'
                              : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: _deadline == null ? AppColors.darkText3 : AppColors.lightGrey),
                        ),
                      ]),
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
                child: Center(child: isLoading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: AppColors.lightGrey, strokeWidth: 2))
                    : Text('Create Goal',
                        style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
