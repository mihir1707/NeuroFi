class CategorySpendingModel {
  final String categoryName; 
  final String icon;         
  final String color;       
  final double amount;       
  final double percentage;   

  CategorySpendingModel({
    required this.categoryName,
    this.icon = '📦',
    this.color = '#64748B',
    required this.amount,
    this.percentage = 0,
  });

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) {
    return CategorySpendingModel(
      categoryName: json['name'] ?? json['category'] ?? '',
      icon:         json['icon'] ?? '📦',
      color:        json['color'] ?? '#64748B',
      amount:       (json['amount'] ?? 0).toDouble(),
      percentage:   (json['percentage'] ?? 0).toDouble(),
    );
  }
}


class MonthlyDataPointModel {
  final int month;          
  final String monthName;   
  final double income;      
  final double expense;     
  final double savings;    

  MonthlyDataPointModel({
    required this.month,
    required this.monthName,
    this.income = 0,
    this.expense = 0,
    this.savings = 0,
  });

  factory MonthlyDataPointModel.fromJson(Map<String, dynamic> json) {
    final income  = (json['income'] ?? 0).toDouble();
    final expense = (json['expense'] ?? json['expenses'] ?? 0).toDouble();
    return MonthlyDataPointModel(
      month:     json['month'] ?? 0,
      monthName: json['monthName'] ?? '',
      income:    income,
      expense:   expense,
      savings:   income - expense,
    );
  }
}


class MonthlyReportModel {
  final int year;                               
  final int month;                              
  final double totalIncome;                     
  final double totalExpenses;                   
  final double netSavings;                      
  final int transactionCount;                   
  final List<CategorySpendingModel> categoryBreakdown;

  MonthlyReportModel({
    required this.year,
    required this.month,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.netSavings = 0,
    this.transactionCount = 0,
    this.categoryBreakdown = const [],
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? json;
    return MonthlyReportModel(
      year:              json['year'] ?? 0,
      month:             json['month'] ?? 0,
      totalIncome:       (summary['totalIncome'] ?? 0).toDouble(),
      totalExpenses:     (summary['totalExpenses'] ?? 0).toDouble(),
      netSavings:        (summary['netSavings'] ?? 0).toDouble(),
      transactionCount:  summary['transactionCount'] ?? 0,
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>? ?? [])
                          .map((c) => CategorySpendingModel.fromJson(c))
                          .toList(),
    );
  }

  bool get isPositive => netSavings >= 0;
}


class OverviewReportModel {
  final double netWorth;      
  final double totalAssets;   
  final double totalLiabilities; 
  final double totalBalance; 

  OverviewReportModel({
    this.netWorth = 0,
    this.totalAssets = 0,
    this.totalLiabilities = 0,
    this.totalBalance = 0,
  });

  factory OverviewReportModel.fromJson(Map<String, dynamic> json) {
    return OverviewReportModel(
      netWorth:         (json['netWorth'] ?? 0).toDouble(),
      totalAssets:      (json['totalAssets'] ?? 0).toDouble(),
      totalLiabilities: (json['totalLiabilities'] ?? 0).toDouble(),
      totalBalance:     (json['totalBalance'] ?? 0).toDouble(),
    );
  }
}


class YearlyReportModel {
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double netSavings;
  final List<MonthlyDataPointModel> monthlyBreakdown; 

  YearlyReportModel({
    required this.year,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.netSavings = 0,
    this.monthlyBreakdown = const [],
  });

  factory YearlyReportModel.fromJson(Map<String, dynamic> json) {
    return YearlyReportModel(
      year:             json['year'] ?? 0,
      totalIncome:      (json['totalIncome'] ?? 0).toDouble(),
      totalExpenses:    (json['totalExpenses'] ?? 0).toDouble(),
      netSavings:       (json['netSavings'] ?? 0).toDouble(),
      monthlyBreakdown: (json['monthlyBreakdown'] as List<dynamic>? ?? []).map((m) => MonthlyDataPointModel.fromJson(m)).toList(),
    );
  }
}
