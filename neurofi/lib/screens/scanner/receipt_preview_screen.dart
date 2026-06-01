import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../router/route_names.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  const ReceiptPreviewScreen({super.key});
  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  final _amountController = TextEditingController(text: '249.00');
  final _merchantController = TextEditingController(text: 'Big Bazaar');
  final _dateController = TextEditingController(text: '2026-05-30');
  String _suggestedCategory = '🛒 Groceries';

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _dateController.dispose();
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
        title: Text('Receipt Preview',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.forest, AppColors.green]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.lightGrey, size: 14),
                      const SizedBox(width: 6),
                      Text('AI Extracted',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.lightGrey, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.red, fontWeight: FontWeight.w800),
                    decoration: _dec.copyWith(labelText: 'Amount Detected',
                        prefixText: '₹ '),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _merchantController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(
                      labelText: 'Merchant / Description',
                      prefixIcon: const Icon(Icons.store_outlined, color: AppColors.darkText3, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dateController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.darkText3, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('AI Suggested Category',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['🛒 Groceries', '🍔 Food', '🛍️ Shopping', '💡 Utilities']
                        .map((c) {
                      final selected = c == _suggestedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _suggestedCategory = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(colors: [AppColors.forest, AppColors.green])
                                : null,
                            color: selected ? null : AppColors.darkBg1,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: selected ? AppColors.green : AppColors.darkBorder),
                          ),
                          child: Text(c,
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: selected ? AppColors.lightGrey : AppColors.darkText2)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, RouteNames.addTransaction),
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add_rounded, color: AppColors.lightGrey, size: 20),
                  const SizedBox(width: 8),
                  Text('Create Transaction',
                      style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
