class SubscriptionInsightModel {
  final int totalMonthlyCost;
  final List<SubscriptionModel> subscriptions;
  final List<ZombieAlertModel> alerts;
  final String insightsSummary;

  SubscriptionInsightModel({
    this.totalMonthlyCost = 0,
    this.subscriptions = const [],
    this.alerts = const [],
    this.insightsSummary = '',
  });

  factory SubscriptionInsightModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionInsightModel(
      totalMonthlyCost: json['totalMonthlyCost'] ?? 0,
      subscriptions: (json['subscriptions'] as List<dynamic>? ?? [])
          .map((e) => SubscriptionModel.fromJson(e))
          .toList(),
      alerts: (json['alerts'] as List<dynamic>? ?? [])
          .map((e) => ZombieAlertModel.fromJson(e))
          .toList(),
      insightsSummary: json['insightsSummary'] ?? '',
    );
  }
}

class SubscriptionModel {
  final String merchant;
  final double averageAmount;
  final String frequency;
  final String lastBilled;
  final int count;

  SubscriptionModel({
    required this.merchant,
    required this.averageAmount,
    required this.frequency,
    required this.lastBilled,
    required this.count,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      merchant: json['merchant'] ?? '',
      averageAmount: (json['averageAmount'] ?? 0).toDouble(),
      frequency: json['frequency'] ?? '',
      lastBilled: json['lastBilled'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ZombieAlertModel {
  final String title;
  final String message;
  final String severity;
  final String merchant;

  ZombieAlertModel({
    required this.title,
    required this.message,
    required this.severity,
    required this.merchant,
  });

  factory ZombieAlertModel.fromJson(Map<String, dynamic> json) {
    return ZombieAlertModel(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'low',
      merchant: json['merchant'] ?? '',
    );
  }
}
