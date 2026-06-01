class ApiEndpoints {
  static const String auth             = '/auth';
  static const String register         = '/auth/register';
  static const String login            = '/auth/login';
  static const String logout           = '/auth/logout';
  static const String me               = '/auth/me';

  static const String accounts         = '/accounts';
  static String accountById(String id) => '/accounts/$id';

  static const String transactions     = '/transactions';
  static String transactionById(String id) => '/transactions/$id';

  static const String budgets          = '/budgets';
  static String budgetById(String id)  => '/budgets/$id';

  static const String categories       = '/categories';
  static String categoryById(String id) => '/categories/$id';

  static const String savings          = '/savings';
  static String savingById(String id)  => '/savings/$id';
  static String depositToGoal(String id) => '/savings/$id/deposit';

  static const String groups           = '/groups';
  static String groupById(String id)   => '/groups/$id';
  static String groupMembers(String id) => '/groups/$id/members';
  static String groupMemberById(String groupId, String memberId) => '/groups/$groupId/members/$memberId';
  static String groupExpenses(String id) => '/groups/$id/expenses';
  static String groupBalances(String id) => '/groups/$id/balances';

  static const String notifications    = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllRead      = '/notifications/read-all';

  static const String receipts         = '/receipts';
  static String receiptById(String id) => '/receipts/$id';
  static String linkReceipt(String id) => '/receipts/$id/link';

  static const String reportsOverview  = '/reports/overview';
  static const String reportsMonthly   = '/reports/monthly';
  static const String reportsYearly    = '/reports/yearly';
  static const String reportsExport    = '/reports/export';
  static const String reportsCurrency  = '/reports/currency';

  static const String aiCategorize     = '/ai/categorize';
  static const String aiCategorizeBatch = '/ai/categorize/batch';
  static const String aiInsights       = '/ai/insights';
  static const String aiPredictBudget  = '/ai/predict-budget';
  static const String aiChat           = '/ai/chat';

  static const String userProfile      = '/users/profile';
  static const String changePassword   = '/users/change-password';
  static const String deleteAccount    = '/users/account';
}
