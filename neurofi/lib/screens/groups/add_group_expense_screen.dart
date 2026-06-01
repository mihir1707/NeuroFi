import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AddGroupExpenseScreen extends StatefulWidget {
  final String groupId;
  const AddGroupExpenseScreen({super.key, required this.groupId});
  @override
  State<AddGroupExpenseScreen> createState() => _AddGroupExpenseScreenState();
}

class _AddGroupExpenseScreenState extends State<AddGroupExpenseScreen> {
  final _descController = TextEditingController();
  final _amtController  = TextEditingController();
  String _splitType = 'equal';

  @override
  void dispose() {
    _descController.dispose();
    _amtController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Group Expense', style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
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
                  TextField(
                    controller: _descController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amtController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(labelText: 'Total Amount'),
                  ),
                  const SizedBox(height: 20),
                  Text('Split Type', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['equal', 'custom'].map((t) {
                      final sel = t == _splitType;
                      return Expanded(child: GestureDetector(
                        onTap: () => setState(() => _splitType = t),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: sel ? const LinearGradient(colors: [AppColors.forest, AppColors.green]) : null,
                            color: sel ? null : AppColors.darkBg1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? AppColors.green : AppColors.darkBorder),
                          ),
                          child: Center(child: Text(t[0].toUpperCase() + t.substring(1),
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: sel ? AppColors.lightGrey : AppColors.darkText2))),
                        ),
                      ));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text('Add Expense',
                    style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
