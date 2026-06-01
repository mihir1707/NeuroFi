import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/transaction_provider.dart';
import 'dart:math' as math;

class SpendingDonutChart extends StatelessWidget {
  const SpendingDonutChart({super.key});

  static const _categoryColors = [
    AppColors.green,
    AppColors.amber,
    AppColors.salmon,
    AppColors.sage,
    AppColors.peach,
    AppColors.pink,
    AppColors.yellow,
    AppColors.forest,
  ];

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;

    final expenses = transactions
        .where((t) => t.isExpense)
        .toList();

    final Map<String, double> categoryTotals = {};
    for (final t in expenses) {
      final cat = t.displayCategory;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + t.amount;
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top     = sorted.take(5).toList();
    final total   = top.fold<double>(0, (s, e) => s + e.value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding:    const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:        AppColors.darkBg1,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey),
            ),
            const SizedBox(height: 20),
            top.isEmpty
                ? _emptyState()
                : Row(
                    children: [
                      SizedBox(
                        width:  140,
                        height: 140,
                        child: CustomPaint(
                          painter: _DonutPainter(
                            segments: top
                                .asMap()
                                .entries
                                .map((e) => _Segment(
                                      value: e.value.value,
                                      color: _categoryColors[
                                          e.key % _categoryColors.length],
                                    ))
                                .toList(),
                            total: total,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: top.asMap().entries.map((e) {
                            final color = _categoryColors[e.key % _categoryColors.length];
                            final pct   = total > 0
                                ? (e.value.value / total * 100).toStringAsFixed(1)
                                : '0';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width:  10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color:  color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.value.key,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.darkText2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '$pct%',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color:      AppColors.lightGrey,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No expense data yet',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
        ),
      ),
    );
  }
}

class _Segment {
  final double value;
  final Color  color;
  const _Segment({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  final double         total;

  const _DonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width  / 2;
    final cy     = size.height / 2;
    final radius = size.width  / 2;
    final stroke = 22.0;
    final rect   = Rect.fromCircle(center: Offset(cx, cy), radius: radius - stroke / 2);
    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      final sweep = total > 0 ? (seg.value / total) * 2 * math.pi : 0.0;
      canvas.drawArc(
        rect,
        startAngle,
        sweep - 0.04,
        false,
        Paint()
          ..color       = seg.color
          ..strokeWidth = stroke
          ..style       = PaintingStyle.stroke
          ..strokeCap   = StrokeCap.round,
      );
      startAngle += sweep;
    }

    final centerPaint = Paint()
      ..color = AppColors.darkBg1
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), radius - stroke, centerPaint);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.segments != segments;
}
