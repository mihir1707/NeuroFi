class AiInsightModel {
  final String title;    
  final String body;     
  final String type;     
  final String icon;     
  final String priority; 

  AiInsightModel({
    required this.title,
    required this.body,
    this.type = 'spending_pattern',
    this.icon = '💡',
    this.priority = 'medium',
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      title:    json['title'] ?? '',
      body:     json['body'] ?? json['description'] ?? '',
      type:     json['type'] ?? 'spending_pattern',
      icon:     json['icon'] ?? '💡',
      priority: json['priority'] ?? 'medium',
    );
  }

  bool get isHighPriority => priority == 'high';
}


class BudgetPredictionModel {
  final String category;       
  final String categoryIcon;   
  final double predictedAmount;
  final double lastMonthSpent; 

  BudgetPredictionModel({
    required this.category,
    this.categoryIcon = '📦',
    required this.predictedAmount,
    this.lastMonthSpent = 0,
  });

  factory BudgetPredictionModel.fromJson(Map<String, dynamic> json) {
    return BudgetPredictionModel(
      category:        json['category'] ?? '',
      categoryIcon:    json['icon'] ?? '📦',
      predictedAmount: (json['predictedAmount'] ?? 0).toDouble(),
      lastMonthSpent:  (json['lastMonthSpent'] ?? 0).toDouble(),
    );
  }

  double get changeAmount => predictedAmount - lastMonthSpent;

  bool get isHigherThanLastMonth => predictedAmount > lastMonthSpent;
}
