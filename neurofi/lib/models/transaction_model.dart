import 'category_model.dart';
import '../core/utils/currency_formatter.dart';

class TransactionModel {
  final String id;                
  final String userId;            
  final String accountId;         
  final String? transferToAccountId;
  final String type;              
  final double amount;            
  final String currency;          
  final String description;       
  final String notes;             
  final CategoryModel? category;  
  final String? categoryId;       
  final String aiCategory;        
  final bool aiCategoryConfirmed; 
  final List<String> tags;        
  final String status;            
  final String transactionDate;   
  final bool isRecurring;       
  final String? recurrenceInterval;
  final String? nextRecurrenceDate; 
  final String? createdAt;        

  TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    this.transferToAccountId,
    required this.type,
    required this.amount,
    this.currency = 'INR',
    this.description = '',
    this.notes = '',
    this.category,
    this.categoryId,
    this.aiCategory = '',
    this.aiCategoryConfirmed = false,
    this.tags = const [],
    this.status = 'posted',
    required this.transactionDate,
    this.isRecurring = false,
    this.recurrenceInterval,
    this.nextRecurrenceDate,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id:                     json['_id'] ?? '',
      userId:                 json['user'] ?? '',
      accountId:              json['account'] is Map ? json['account']['_id'] ?? '' : json['account'] ?? '',
      transferToAccountId:    json['transferToAccount'],
      type:                   json['type'] ?? 'expense',
      amount:                 (json['amount'] ?? 0).toDouble(),
      currency:               json['currency'] ?? 'INR',
      description:            json['description'] ?? '',
      notes:                  json['notes'] ?? '',
      category:               json['category'] is Map ? CategoryModel.fromJson(json['category']) : null,
      categoryId:             json['category'] is String ? json['category'] : null,
      aiCategory:             json['aiCategory'] ?? '',
      aiCategoryConfirmed:    json['aiCategoryConfirmed'] ?? false,
      tags:                   List<String>.from(json['tags'] ?? []),
      status:                 json['status'] ?? 'posted',
      transactionDate:        json['transactionDate'] ?? '',
      isRecurring:            json['isRecurring'] ?? false,
      recurrenceInterval:     json['recurrenceInterval'],
      nextRecurrenceDate:     json['nextRecurrenceDate'],
      createdAt:              json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account':              accountId,
      'type':                 type,
      'amount':               amount,
      'currency':             currency,
      'description':          description,
      'notes':                notes,
      'tags':                 tags,
      'transactionDate':      transactionDate,
      'isRecurring':          isRecurring,
      if (recurrenceInterval != null) 'recurrenceInterval': recurrenceInterval,
      if (categoryId != null) 'category': categoryId,
    };
  }

  bool get isIncome   => type == 'income';
  bool get isExpense  => type == 'expense';
  bool get isTransfer => type == 'transfer';

  String get signedAmount {
    if (isIncome) return '+${CurrencyFormatter.symbolFor(currency)}${amount.toStringAsFixed(0)}';
    return '−${CurrencyFormatter.symbolFor(currency)}${amount.toStringAsFixed(0)}';
  }

  String get displayCategory {
    if (category != null) return category!.name;
    if (aiCategory.isNotEmpty) return aiCategory;
    return 'Uncategorized';
  }
}