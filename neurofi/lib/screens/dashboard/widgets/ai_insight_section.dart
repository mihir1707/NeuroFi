import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/ai_provider.dart';
import '../../../models/ai_insight_model.dart';
import '../../../router/route_names.dart';

class AiInsightSection extends StatefulWidget {
  const AiInsightSection({super.key});

  @override
  State<AiInsightSection> createState() => _AiInsightSectionState();
}

class _AiInsightSectionState extends State<AiInsightSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiProvider>().loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();
    final insights   = aiProvider.insights;
    final isLoading  = aiProvider.isLoadingInsights;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width:  30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI Insights',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, RouteNames.aiInsights),
                child: Text(
                  'View all',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoading)
            _shimmerCard()
          else if (insights.isEmpty)
            _tipCard(
              emoji:   '💡',
              title:   'Smart tip',
              message: 'Add transactions to get personalized AI insights about your spending habits.',
              color:   AppColors.amber,
            )
          else
            Column(
              children: insights
                  .take(2)
                  .map((i) => _insightCard(i))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _insightCard(AiInsightModel insight) {
    return _tipCard(
      emoji:   insight.icon,
      title:   insight.title,
      message: insight.body,
      color:   insight.isHighPriority ? AppColors.red : AppColors.amber,
    );
  }

  Widget _tipCard({
    required String emoji,
    required String title,
    required String message,
    required Color  color,
  }) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: const Color(0x33FFFFFF)),

      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  38,
            height: 38,
            decoration: BoxDecoration(
              color:        const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color:      Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color:  Colors.white.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      height:  80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width:  38,
            height: 38,
            decoration: BoxDecoration(
              color:        const Color(0xFF222222),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Container(
                  height:       12,
                  width:        120,
                  decoration: BoxDecoration(
                    color:        const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height:       10,
                  decoration: BoxDecoration(
                    color:        const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
