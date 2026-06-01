class AppConstants {
  static const String appName        = 'NeuroFi';
  static const String appVersion     = '1.0.0';
  static const String defaultCurrency = 'INR';
  static const String currencySymbol  = '₹';

  static const int defaultPageLimit   = 20;
  static const int splashDuration     = 2;

  static const String tokenKey        = 'token';
  static const String userKey         = 'user';
  static const String themeKey        = 'isDarkMode';

  static const List<String> accountTypes = [
    'bank',
    'cash',
    'credit_card',
    'debit_card',
    'wallet',
    'investment',
    'loan',
  ];

  static const List<String> transactionTypes = [
    'income',
    'expense',
    'transfer',
  ];

  static const List<String> budgetPeriods = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

  static const List<String> recurrenceIntervals = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

  static const List<String> currencies = [
    'INR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SGD',
    'JPY',
    'CAD',
    'AUD',
  ];

  static const List<String> categoryEmojis = [
    '🍕', '🚇', '🛒', '⚡', '🏠', '💊', '🎮', '📚',
    '✈️', '💼', '🎬', '☕', '🏋️', '💅', '🐾', '🎁',
    '📱', '🚗', '🏦', '💰', '📈', '🎯', '🏖️', '🎓',
  ];

  static const List<String> categoryColors = [
    '#7C3AED', '#06B6D4', '#DB2777', '#F59E0B',
    '#10B981', '#3B82F6', '#EF4444', '#8B5CF6',
    '#EC4899', '#14B8A6', '#F97316', '#84CC16',
  ];
}
