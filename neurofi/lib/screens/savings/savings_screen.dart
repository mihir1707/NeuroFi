import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/savings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/savings_goal_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../router/route_names.dart';
import 'dart:math' as math;

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});
  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider  = context.watch<SavingsProvider>();
    final currency  = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final goals     = provider.goals;
    final isLoading = provider.isLoading;

    final totalSaved  = goals.fold<double>(0, (s, g) => s + g.currentAmount);
    final totalTarget = goals.fold<double>(0, (s, g) => s + g.targetAmount);

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadGoals(),
          color: AppColors.green,
          backgroundColor: AppColors.darkBg1,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (goals.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSummary(totalSaved, totalTarget, currency)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (isLoading)
                SliverList(delegate: SliverChildBuilderDelegate(
                  (_, __) => _shimmer(), childCount: 3))
              else if (goals.isEmpty)
                SliverToBoxAdapter(child: _emptyState(context))
              else
                SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => _GoalCard(goal: goals[i], currency: currency),
                  childCount: goals.length,
                )),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Savings Goals',
            style: AppTextStyles.headingLarge.copyWith(color: AppColors.lightGrey)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, RouteNames.addSavingsGoal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.add_rounded, color: AppColors.lightGrey, size: 16),
              const SizedBox(width: 4),
              Text('Add', style: AppTextStyles.labelMedium.copyWith(color: AppColors.lightGrey)),
            ]),
          ),
        ),
      ],
    ),
  );

  Widget _buildSummary(double saved, double target, String currency) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.darkForest, AppColors.darkBg1],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.forest.withOpacity(0.4)),
      ),
      child: Row(children: [
        const Text('💰', style: TextStyle(fontSize: 36)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Saved',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.sage)),
              Text(CurrencyFormatter.format(saved, currency),
                  style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.lightGrey, fontWeight: FontWeight.w800)),
              Text('of ${CurrencyFormatter.format(target, currency)} target',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
            ],
          ),
        ),
      ]),
    ),
  );

  Widget _shimmer() => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    height: 100,
    decoration: BoxDecoration(
      color: AppColors.darkBg1, borderRadius: BorderRadius.circular(16)),
  );

  Widget _emptyState(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(children: [
      const Text('🎯', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text('No savings goals yet',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText2)),
      const SizedBox(height: 6),
      Text('Set a goal and start saving today',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, RouteNames.addSavingsGoal),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Create Goal',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.lightGrey)),
        ),
      ),
    ]),
  );
}

class _GoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final String currency;
  const _GoalCard({required this.goal, required this.currency});

  @override
  Widget build(BuildContext context) {
    final pct   = goal.progressFraction.clamp(0.0, 1.0);
    final color = goal.isCompleted ? AppColors.green
        : pct > 0.7 ? AppColors.amber : AppColors.sage;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.savingsDetail, arguments: goal.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: goal.isCompleted
                  ? AppColors.green.withOpacity(0.3) : AppColors.darkBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56, height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(56, 56),
                    painter: _RingPainter(pct, color),
                  ),
                  Text(goal.icon, style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(goal.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lightGrey, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (goal.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Done ✓',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.green)),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyFormatter.formatCompact(goal.currentAmount, currency)} / ${CurrencyFormatter.formatCompact(goal.targetAmount, currency)}',
                    style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 4,
                      backgroundColor: AppColors.darkBg2,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  if (goal.targetDate != null) ...[
                    const SizedBox(height: 4),
                    Text('Target: ${_formatDate(goal.targetDate!)}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.darkText3, size: 18),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color  color;
  const _RingPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 4;
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = AppColors.darkBg2..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, value * 2 * math.pi, false,
      Paint()..color = color..style = PaintingStyle.stroke
        ..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}
