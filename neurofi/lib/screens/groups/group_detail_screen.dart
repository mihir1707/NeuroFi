import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../router/route_names.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

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
        title: Text('Group Detail', style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.sage, size: 22),
            onPressed: () => Navigator.pushNamed(context, RouteNames.addGroupExpense, arguments: groupId),
          ),
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('💸', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No expenses yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText2)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.settlement, arguments: groupId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('View Settlements', style: AppTextStyles.labelMedium.copyWith(color: AppColors.lightGrey)),
            ),
          ),
        ]),
      ),
    );
  }
}
