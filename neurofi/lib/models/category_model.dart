class CategoryModel {
  final String id;          
  final String? userId;     
  final String name;        
  final String type;        
  final String icon;        
  final String color;       
  final bool isDefault;     
  final bool isActive;      
  final int sortOrder;      

  CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    this.icon = '📦',
    this.color = '#64748B',
    this.isDefault = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id:        json['_id'] ?? '',
      userId:    json['user'],
      name:      json['name'] ?? '',
      type:      json['type'] ?? 'expense',
      icon:      json['icon'] ?? '📦',
      color:     json['color'] ?? '#64748B',
      isDefault: json['isDefault'] ?? false,
      isActive:  json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name':  name,
      'type':  type,
      'icon':  icon,
      'color': color,
    };
  }

  bool get isExpense => type == 'expense';

  bool get isIncome => type == 'income';

  bool get isEditable => !isDefault;
}