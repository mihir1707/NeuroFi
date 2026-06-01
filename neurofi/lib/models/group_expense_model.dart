class SplitDetailModel {
  final String userId;
  final String name;
  final double amount;
  final bool isPaid;

  SplitDetailModel({
    required this.userId,
    required this.name,
    required this.amount,
    this.isPaid = false,
  });

  factory SplitDetailModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return SplitDetailModel(
      userId: user is Map ? user['_id'] ?? '' : user ?? '',
      name: user is Map ? user['name'] ?? '' : '',
      amount: (json['amount'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
    );
  }
}

class GroupExpenseModel {
  final String id;
  final String groupId;
  final String paidByUserId;
  final String paidByName;
  final double amount;
  final String currency;
  final String description;
  final String category;
  final String splitType;
  final List<SplitDetailModel> splits;
  final String expenseDate;
  final String? createdAt;

  GroupExpenseModel({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    this.paidByName = '',
    required this.amount,
    this.currency = 'INR',
    this.description = '',
    this.category = '',
    this.splitType = 'equal',
    this.splits = const [],
    required this.expenseDate,
    this.createdAt,
  });

  factory GroupExpenseModel.fromJson(Map<String, dynamic> json) {
    final paidBy = json['paidBy'];
    return GroupExpenseModel(
      id: json['_id'] ?? '',
      groupId: json['group'] ?? '',
      paidByUserId: paidBy is Map ? paidBy['_id'] ?? '' : paidBy ?? '',
      paidByName: paidBy is Map ? paidBy['name'] ?? '' : '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      splitType: json['splitType'] ?? 'equal',
      splits: (json['splits'] as List<dynamic>? ?? [])
          .map((s) => SplitDetailModel.fromJson(s))
          .toList(),
      expenseDate: json['expenseDate'] ?? '',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'currency': currency,
      'category': category,
      'splitType': splitType,
      'expenseDate': expenseDate,
    };
  }

  double amountForUser(String userId) {
    final split = splits.where((s) => s.userId == userId);
    if (split.isEmpty) return 0;
    return split.first.amount;
  }
}
