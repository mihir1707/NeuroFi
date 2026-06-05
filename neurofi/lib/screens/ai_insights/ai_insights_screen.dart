import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/ai_provider.dart';
import '../../models/ai_insight_model.dart';
import 'dart:math' as math;

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});
  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiProvider>().loadInsights();
      context.read<AiProvider>().loadBudgetPredictions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider     = context.watch<AiProvider>();
    final insights     = provider.insights;
    final predictions  = provider.predictions;
    final isLoading    = provider.isLoadingInsights;

    final score = _calcScore(insights);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('AI Insights',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            onPressed: () {
              provider.loadInsights();
              provider.loadBudgetPredictions();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreRing(score),
                  const SizedBox(height: 24),
                  
                  // Subscription Hunter Banner
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/subscriptions'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.manage_search_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subscription Hunter',
                                    style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('Find zombie bills & save money',
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (insights.isNotEmpty) ...[
                    Text('Smart Insights',
                        style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                    const SizedBox(height: 12),
                    ...insights.map((i) => _InsightCard(insight: i)),
                  ],
                  if (predictions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Budget Predictions',
                        style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                    const SizedBox(height: 12),
                    ...predictions.map((p) => _PredictionCard(prediction: p)),
                  ],
                  if (insights.isEmpty && predictions.isEmpty)
                    _emptyState(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  int _calcScore(List<AiInsightModel> insights) {
    if (insights.isEmpty) return 72;
    final high = insights.where((i) => i.isHighPriority).length;
    return (85 - high * 10).clamp(40, 95);
  }

  Widget _buildScoreRing(int score) {
    final color = score >= 80 ? Colors.green
        : score >= 60 ? Colors.amber : Colors.red;
    final label = score >= 80 ? 'Excellent' : score >= 60 ? 'Good' : 'Needs Work';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(90, 90),
                  painter: _ArcPainter(score / 100, color),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$score', style: AppTextStyles.headingLarge.copyWith(
                        color: color, fontSize: 26, fontWeight: FontWeight.w800)),
                    Text('/100', style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Financial Health', style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.6))),
                Text(label, style: AppTextStyles.headingMedium.copyWith(
                    color: color, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  score >= 80 ? 'Great habits! Keep it up 🎉'
                      : score >= 60 ? 'Room for improvement 💪'
                      : 'Action needed ⚠️',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Column(children: [
        const Text('🤖', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text('No insights yet', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.6))),
        const SizedBox(height: 6),
        Text('Add more transactions to get AI analysis',
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.4))),
      ]),
    ),
  );
}

class _InsightCard extends StatelessWidget {
  final AiInsightModel insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final color = insight.isHighPriority ? Colors.red : Colors.amber;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(insight.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(insight.title,
                      style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700))),
                  if (insight.isHighPriority)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('High Priority',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.red, fontSize: 9)),
                    ),
                ]),
                const SizedBox(height: 4),
                Text(insight.body, style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final BudgetPredictionModel prediction;
  const _PredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final color = prediction.isHigherThanLastMonth ? Colors.red : Colors.green;
    final icon  = prediction.isHigherThanLastMonth ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        children: [
          Text(prediction.categoryIcon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prediction.category,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                Text('Last month: ${prediction.lastMonthSpent.toStringAsFixed(0)}',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(prediction.predictedAmount.toStringAsFixed(0),
                  style: AppTextStyles.labelMedium.copyWith(
                      color: color, fontWeight: FontWeight.w700)),
              Row(children: [
                Icon(icon, color: color, size: 12),
                Text(prediction.changeAmount.abs().toStringAsFixed(0),
                    style: AppTextStyles.labelSmall.copyWith(color: color)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color  color;
  const _ArcPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 6;
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = const Color(0xFF111111)..style = PaintingStyle.stroke..strokeWidth = 8);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, value.clamp(0, 1) * 2 * math.pi, false,
      Paint()..color = color..style = PaintingStyle.stroke
        ..strokeWidth = 8..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value;
}
