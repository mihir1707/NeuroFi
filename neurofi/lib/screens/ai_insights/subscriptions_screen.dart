import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/ai_provider.dart';
import '../../../providers/auth_provider.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiProvider>().loadSubscriptionInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();
    final currency = context.watch<AuthProvider>().user?.currency ?? 'INR';
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Subscription Hunter',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: aiProvider.isLoadingSubscriptions
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _buildContent(aiProvider, currency),
    );
  }

  Widget _buildContent(AiProvider provider, String currency) {
    final insights = provider.subscriptionInsights;
    if (insights == null || insights.subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text('No subscriptions detected',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadSubscriptionInsights(),
      color: Colors.black,
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Total Monthly Cost Banner
          _buildTotalBanner(insights.totalMonthlyCost.toDouble(), currency),
          const SizedBox(height: 24),
          
          // Zombie Alerts
          if (insights.alerts.isNotEmpty) ...[
            Text('🚨 AI Alerts',
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...insights.alerts.map((a) => _buildAlertCard(a)),
            const SizedBox(height: 24),
          ],

          // Subscriptions List
          Text('Active Subscriptions',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...insights.subscriptions.map((s) => _buildSubscriptionRow(s, currency)),
        ],
      ),
    );
  }

  Widget _buildTotalBanner(double total, String currency) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Total Monthly Cost',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
          const SizedBox(height: 8),
          Text(CurrencyFormatter.format(total, currency),
              style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text('Audited by AI',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlertCard(dynamic alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(alert.message,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.lightGrey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionRow(dynamic sub, String currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(sub.merchant.isNotEmpty ? sub.merchant[0].toUpperCase() : 'S',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Capitalize merchant name
                  sub.merchant.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text('${sub.frequency} • Billed ${sub.count} times',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
              ],
            ),
          ),
          Text(CurrencyFormatter.format(sub.averageAmount, currency),
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
