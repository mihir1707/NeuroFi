class NotificationModel {
  final String id;        
  final String userId;    
  final String title;     
  final String body;      
  final String type;      
  final bool isRead;      
  final String? link;     
  final String? createdAt; 

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'general',
    this.isRead = false,
    this.link,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:        json['_id'] ?? '',
      userId:    json['user'] ?? '',
      title:     json['title'] ?? '',
      body:      json['body'] ?? '',
      type:      json['type'] ?? 'general',
      isRead:    json['isRead'] ?? false,
      link:      json['link'],
      createdAt: json['createdAt'],
    );
  }

  String get icon {
    switch (type) {
      case 'budget_alert':   return '⚠️';
      case 'bill_reminder':  return '🔔';
      case 'goal_update':    return '🎯';
      case 'group_expense':  return '👥';
      case 'monthly_report': return '📊';
      default:               return '📣';
    }
  }

  String get dotColor {
    switch (type) {
      case 'budget_alert':   return '#F59E0B';
      case 'bill_reminder':  return '#06B6D4';
      case 'goal_update':    return '#10B981';
      case 'group_expense':  return '#7C3AED';
      default:               return '#64748B';
    }
  }
}