import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/savings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/savings_goal_model.dart';
import '../../core/utils/currency_formatter.dart';
import 'dart:math' as math;

class SavingsGoalDetailScreen extends StatefulWidget {
  final String goalId;
  const SavingsGoalDetailScreen({super.key, required this.goalId});
  @override
  State<SavingsGoalDetailScreen> createState() => _SavingsGoalDetailScreenState();
}

class _SavingsGoalDetailScreenState extends State<SavingsGoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadGoalById(widget.goalId);
    });
  }

  void _showDeposit(SavingsGoalModel goal, String currency) {
    final amtCtrl  = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.darkBg1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: AppColors.darkBg2,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Add Deposit', style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
              const SizedBox(height: 20),
              TextField(
                controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${CurrencyFormatter.symbolFor(currency)} ',
                  prefixStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.sage),
                  labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
                  filled: true, fillColor: AppColors.darkBg2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
                  filled: true, fillColor: AppColors.darkBg2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final amount = double.tryParse(amtCtrl.text) ?? 0;
                  if (amount <= 0) return;
                  Navigator.pop(context);
                  await context.read<SavingsProvider>().deposit(
                    goalId: widget.goalId,
                    amount: amount,
                    notes:  noteCtrl.text,
                  );
                },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text('Deposit',
                      style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<SavingsProvider>();
    final goal      = provider.selectedGoal;
    final isLoading = provider.isLoading;
    final currency  = context.watch<AuthProvider>().user?.currency ?? 'INR';

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(goal?.name ?? 'Goal Detail',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
      ),
      body: isLoading || goal == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : _buildBody(goal, currency),
    );
  }

  Widget _buildBody(SavingsGoalModel goal, String currency) {
    final pct   = goal.progressFraction.clamp(0.0, 1.0);
    final color = goal.isCompleted ? AppColors.green : pct > 0.7 ? AppColors.amber : AppColors.sage;
    final daysLeft = goal.targetDate != null
        ? DateTime.parse(goal.targetDate!).difference(DateTime.now()).inDays
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.12), AppColors.darkBg1],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 110, height: 110,
                  child: Stack(alignment: Alignment.center, children: [
                    CustomPaint(size: const Size(110, 110), painter: _RingPainter(pct, color)),
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(goal.icon, style: const TextStyle(fontSize: 30)),
                      Text('${(pct * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                Text(goal.name, style: AppTextStyles.headingMedium.copyWith(color: AppColors.lightGrey)),
                if (goal.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(goal.description,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText2),
                      textAlign: TextAlign.center),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem('Saved', CurrencyFormatter.formatCompact(goal.currentAmount, currency), AppColors.green),
                    _statItem('Target', CurrencyFormatter.formatCompact(goal.targetAmount, currency), AppColors.sage),
                    _statItem('Left', CurrencyFormatter.formatCompact(goal.remainingAmount, currency), AppColors.amber),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct, minHeight: 8,
                    backgroundColor: AppColors.darkBg2,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                if (daysLeft != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    daysLeft > 0 ? '$daysLeft days remaining' : 'Deadline passed',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: daysLeft > 0 ? AppColors.darkText3 : AppColors.red),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!goal.isCompleted)
            GestureDetector(
              onTap: () => _showDeposit(goal, currency),
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add_rounded, color: AppColors.lightGrey, size: 20),
                  const SizedBox(width: 6),
                  Text('Add Deposit',
                      style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey)),
                ]),
              ),
            ),
          if (goal.isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                const SizedBox(width: 8),
                Text('Goal Achieved! 🎉',
                    style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.green, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, Color color) {
    return Column(children: [
      Text(val, style: AppTextStyles.titleMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
      Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
    ]);
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color  color;
  const _RingPainter(this.value, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 6;
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = AppColors.darkBg2..style = PaintingStyle.stroke..strokeWidth = 8);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, value * 2 * math.pi, false,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}
