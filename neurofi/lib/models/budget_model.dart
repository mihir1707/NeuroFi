import 'category_model.dart';

class BudgetModel {
  final String id;                  
  final String userId;              
  final CategoryModel? category;    
  final String? categoryId;         
  final double amount;              
  final double spent;               
  final String currency;            
  final String period;              
  final int alertThreshold;         
  final String status;              
  final bool isActive;              
  final String startDate;           
  final String? endDate;            
  final String? createdAt;          

  BudgetModel({
    required this.id,
    required this.userId,
    this.category,
    this.categoryId,
    required this.amount,
    this.spent = 0,
    this.currency = 'INR',
    this.period = 'monthly',
    this.alertThreshold = 80,
    this.status = 'good',
    this.isActive = true,
    required this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id:             json['_id'] ?? '',
      userId:         json['user'] ?? '',
      category:       json['category'] is Map ? CategoryModel.fromJson(json['category']) : null,
      categoryId:     json['category'] is String ? json['category'] : null,
      amount:         (json['amount'] ?? 0).toDouble(),
      spent:          (json['spent'] ?? 0).toDouble(),
      currency:       json['currency'] ?? 'INR',
      period:         json['period'] ?? 'monthly',
      alertThreshold: json['alertThreshold'] ?? 80,
      status:         json['status'] ?? 'good',
      isActive:       json['isActive'] ?? true,
      startDate:      json['startDate'] ?? '',
      endDate:        json['endDate'],
      createdAt:      json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category':        categoryId,
      'amount':          amount,
      'currency':        currency,
      'period':          period,
      'alertThreshold':  alertThreshold,
      'startDate':       startDate,
    };
  }

  double get percentUsed {
    if (amount <= 0) return 0;
    return (spent / amount * 100).clamp(0, 100);
  }

  double get remaining => (amount - spent).clamp(0, double.infinity);

  bool get isWarning => percentUsed >= alertThreshold && percentUsed < 100;

  bool get isExceeded => spent > amount;
}
