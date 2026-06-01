class AccountModel {
  final String id;              
  final String userId;           
  final String name;             
  final String type;             
  final String institution;      
  final double balance;          
  final String currency;         
  final String accountNumberLast4;
  final String icon;            
  final String color;           
  final bool isArchived;        
  final String? createdAt;       

  AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    this.institution = '',
    this.currency = 'INR',
    this.accountNumberLast4 = '',
    this.icon = '🏦',
    this.color = '#3B82F6',
    this.isArchived = false,
    this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id:                   json['_id'] ?? '',
      userId:               json['user'] ?? '',
      name:                 json['name'] ?? '',
      type:                 json['type'] ?? 'bank',
      institution:          json['institution'] ?? '',
      balance:              (json['balance'] ?? 0).toDouble(),
      currency:             json['currency'] ?? 'INR',
      accountNumberLast4:   json['accountNumberLast4'] ?? '',
      icon:                 json['icon'] ?? '🏦',
      color:                json['color'] ?? '#3B82F6',
      isArchived:           json['isArchived'] ?? false,
      createdAt:            json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name':                 name,
      'type':                 type,
      'institution':          institution,
      'balance':              balance,
      'currency':             currency,
      'accountNumberLast4':   accountNumberLast4,
      'icon':                 icon,
      'color':                color,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'bank':        return 'Bank Account';
      case 'cash':        return 'Cash';
      case 'credit_card': return 'Credit Card';
      case 'debit_card':  return 'Debit Card';
      case 'wallet':      return 'Wallet';
      case 'investment':  return 'Investment';
      case 'loan':        return 'Loan';
      default:            return 'Other';
    }
  }

  bool get isNegative => balance < 0;
}
