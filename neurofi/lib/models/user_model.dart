class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String currency;
  final double monthlyBudget;
  final bool notificationsEnabled;
  final bool aiInsightsEnabled;
  final bool isPremium;
  final bool biometricEnabled;
  final bool isActive;
  final String? lastLoginAt;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.profileImage = '',
    this.currency = 'INR',
    this.monthlyBudget = 0,
    this.notificationsEnabled = true,
    this.aiInsightsEnabled = true,
    this.isPremium = false,
    this.biometricEnabled = false,
    this.isActive = true,
    this.lastLoginAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      currency: json['currency'] ?? 'INR',
      monthlyBudget: (json['monthlyBudget'] ?? 0).toDouble(),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      aiInsightsEnabled: json['aiInsightsEnabled'] ?? true,
      isPremium: json['isPremium'] ?? false,
      biometricEnabled: json['biometricEnabled'] ?? false,
      isActive: json['isActive'] ?? true,
      lastLoginAt: json['lastLoginAt'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'currency': currency,
      'monthlyBudget': monthlyBudget,
      'notificationsEnabled': notificationsEnabled,
      'aiInsightsEnabled': aiInsightsEnabled,
      'isPremium': isPremium,
      'biometricEnabled': biometricEnabled,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImage,
    String? currency,
    double? monthlyBudget,
    bool? notificationsEnabled,
    bool? aiInsightsEnabled,
    bool? biometricEnabled,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      currency: currency ?? this.currency,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}