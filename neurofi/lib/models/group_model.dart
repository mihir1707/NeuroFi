class GroupMemberModel {
  final String userId;   
  final String name;     
  final String email;    
  final String role;     

  GroupMemberModel({
    required this.userId,
    required this.name,
    required this.email,
    this.role = 'member',
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return GroupMemberModel(
      userId: user is Map ? user['_id'] ?? '' : user ?? '',
      name:   user is Map ? user['name'] ?? '' : '',
      email:  user is Map ? user['email'] ?? '' : '',
      role:   json['role'] ?? 'member',
    );
  }
}


class GroupModel {
  final String id;                    
  final String name;                  
  final String description;           
  final String currency;              
  final String icon;                  
  final String color;                 
  final List<GroupMemberModel> members; 
  final String createdBy;             
  final bool isActive;                
  final String? createdAt;            

  GroupModel({
    required this.id,
    required this.name,
    this.description = '',
    this.currency = 'INR',
    this.icon = '👥',
    this.color = '#7C3AED',
    this.members = const [],
    required this.createdBy,
    this.isActive = true,
    this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id:          json['_id'] ?? '',
      name:        json['name'] ?? '',
      description: json['description'] ?? '',
      currency:    json['currency'] ?? 'INR',
      icon:        json['icon'] ?? '👥',
      color:       json['color'] ?? '#7C3AED',
      members:     (json['members'] as List<dynamic>? ?? [])
                    .map((m) => GroupMemberModel.fromJson(m))
                    .toList(),
      createdBy:   json['createdBy'] ?? '',
      isActive:    json['isActive'] ?? true,
      createdAt:   json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name':        name,
      'description': description,
      'currency':    currency,
      'icon':        icon,
      'color':       color,
    };
  }

  int get memberCount => members.length;
}
