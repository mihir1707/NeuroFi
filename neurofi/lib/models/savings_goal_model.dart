class SavingsGoalModel {
  final String id;              
  final String userId;          
  final String name;           
  final String description;     
  final double targetAmount;    
  final double currentAmount;   
  final String currency;        
  final String? targetDate;     
  final String icon;            
  final String color;           
  final String status;          
  final String? createdAt;      

  final double progressPercent; 
  final double remainingAmount; 

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description = '',
    required this.targetAmount,
    this.currentAmount = 0,
    this.currency = 'INR',
    this.targetDate,
    this.icon = '🎯',
    this.color = '#6366F1',
    this.status = 'active',
    this.createdAt,
    this.progressPercent = 0,
    this.remainingAmount = 0,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    final target  = (json['targetAmount'] ?? 0).toDouble();
    final current = (json['currentAmount'] ?? 0).toDouble();

    final progress  = target > 0 ? (current / target * 100).clamp(0.0, 100.0) : 0.0;
    final remaining = (target - current).clamp(0.0, double.infinity);

    return SavingsGoalModel(
      id:              json['_id'] ?? '',
      userId:          json['user'] ?? '',
      name:            json['name'] ?? '',
      description:     json['description'] ?? '',
      targetAmount:    target,
      currentAmount:   current,
      currency:        json['currency'] ?? 'INR',
      targetDate:      json['targetDate'],
      icon:            json['icon'] ?? '🎯',
      color:           json['color'] ?? '#6366F1',
      status:          json['status'] ?? 'active',
      createdAt:       json['createdAt'],
      progressPercent: (json['progressPercent'] ?? progress).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? remaining).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name':          name,
      'description':   description,
      'targetAmount':  targetAmount,
      'currency':      currency,
      'icon':          icon,
      'color':         color,
      if (targetDate != null) 'targetDate': targetDate,
    };
  }

  bool get isCompleted => status == 'completed' || currentAmount >= targetAmount;

  bool get isActive => status == 'active';

  double get progressFraction => progressPercent / 100;
}