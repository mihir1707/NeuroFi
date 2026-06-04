import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/budget_model.dart';
import '../../core/utils/currency_formatter.dart';
import 'dart:math' as math;

class BudgetDetailScreen extends StatefulWidget {
  final String budgetId;
  const BudgetDetailScreen({super.key, required this.budgetId});
  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgetById(widget.budgetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<BudgetProvider>();
    final budget    = provider.selectedBudget;
    final currency  = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(budget?.category?.name ?? 'Budget',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
      ),
      body: isLoading || budget == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _buildRingCard(budget, currency),
                const SizedBox(height: 20),
                _buildDetails(budget, currency),
                const SizedBox(height: 80),
              ]),
            ),
    );
  }

  Widget _buildRingCard(BudgetModel budget, String currency) {
    final pct   = budget.percentUsed / 100;
    final color = budget.isExceeded ? AppColors.red : budget.isWarning ? AppColors.amber : AppColors.green;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), AppColors.darkBg1],
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        SizedBox(
          width: 120, height: 120,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(size: const Size(120, 120), painter: _ArcPainter(pct, color)),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(budget.category?.icon ?? '📊', style: const TextStyle(fontSize: 28)),
              Text('${budget.percentUsed.toStringAsFixed(0)}%',
                  style: AppTextStyles.labelMedium.copyWith(
                      color: color, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _stat('Budgeted', CurrencyFormatter.formatCompact(budget.amount, currency), AppColors.sage),
          _stat('Spent', CurrencyFormatter.formatCompact(budget.spent, currency), AppColors.red),
          _stat('Remaining', CurrencyFormatter.formatCompact(budget.remaining, currency), AppColors.green),
        ]),
      ]),
    );
  }

  Widget _stat(String label, String val, Color color) => Column(children: [
    Text(val, style: AppTextStyles.titleMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
    Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
  ]);

  Widget _buildDetails(BudgetModel budget, String currency) => Container(
    decoration: BoxDecoration(
      color: AppColors.darkBg1,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.darkBorder),
    ),
    child: Column(children: [
      _row('Period', budget.period.toUpperCase(), Icons.calendar_today_outlined),
      Divider(height: 1, color: AppColors.darkBorder, indent: 46),
      _row('Alert At', '${budget.alertThreshold}%', Icons.notifications_outlined),
      Divider(height: 1, color: AppColors.darkBorder, indent: 46),
      _row('Status', budget.isExceeded ? 'Exceeded' : budget.isWarning ? 'Warning' : 'On Track',
          Icons.check_circle_outline_rounded),
    ]),
  );

  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, color: AppColors.darkText3, size: 18),
      const SizedBox(width: 12),
      Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3)),
      const Spacer(),
      Text(value, style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.lightGrey, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color color;
  const _ArcPainter(this.value, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 8;
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = AppColors.darkBg2..style = PaintingStyle.stroke..strokeWidth = 10);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, value.clamp(0, 1) * 2 * math.pi, false,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value;
}
