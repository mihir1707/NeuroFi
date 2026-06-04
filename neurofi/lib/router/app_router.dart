import 'package:flutter/material.dart';
import 'route_names.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/splash/onboarding_screen.dart';
import '../screens/auth/login/login_screen.dart';
import '../screens/auth/register/register_screen.dart';
import '../screens/screens.dart';
import '../screens/main_shell.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RouteNames.splash:
        return _build(const SplashScreen());

      case RouteNames.onboarding:
        return _build(const OnboardingScreen());

      case RouteNames.login:
        return _build(const LoginScreen());

      case RouteNames.register:
        return _build(const RegisterScreen());

      case RouteNames.dashboard:
        return _build(const MainShell());

      case RouteNames.accounts:
        return _build(const AccountsScreen());

      case RouteNames.accountDetail:
        return _build(AccountDetailScreen(accountId: args as String));

      case RouteNames.addAccount:
        return _build(const AddAccountScreen());

      case RouteNames.transactions:
        return _build(const TransactionsScreen());

      case RouteNames.transactionDetail:
        return _build(TransactionDetailScreen(transactionId: args as String));

      case RouteNames.addTransaction:
        return _build(const AddTransactionScreen());

      case RouteNames.budgets:
        return _build(const BudgetsScreen());

      case RouteNames.addBudget:
        return _build(const AddBudgetScreen());

      case RouteNames.budgetDetail:
        return _build(BudgetDetailScreen(budgetId: args as String));

      case RouteNames.savings:
        return _build(const SavingsScreen());

      case RouteNames.addSavingsGoal:
        return _build(const AddSavingsGoalScreen());

      case RouteNames.savingsDetail:
        return _build(SavingsGoalDetailScreen(goalId: args as String));

      case RouteNames.analytics:
        return _build(const AnalyticsScreen());

      case RouteNames.aiChat:
        return _build(const AiChatScreen());

      case RouteNames.aiInsights:
        return _build(const AiInsightsScreen());

      case RouteNames.categories:
        return _build(const CategoriesScreen());

      case RouteNames.addCategory:
        return _build(const AddCategoryScreen());

      case RouteNames.scanner:
        return _build(const ScannerScreen());

      case RouteNames.receiptPreview:
        return _build(const ReceiptPreviewScreen());

      case RouteNames.groups:
        return _build(const GroupsScreen());

      case RouteNames.groupDetail:
        return _build(GroupDetailScreen(groupId: args as String));

      case RouteNames.addGroup:
        return _build(const AddGroupScreen());

      case RouteNames.addGroupExpense:
        return _build(AddGroupExpenseScreen(groupId: args as String));

      case RouteNames.settlement:
        return _build(SettlementScreen(groupId: args as String));

      case RouteNames.notifications:
        return _build(const NotificationsScreen());

      case RouteNames.profile:
        return _build(const ProfileScreen());

      case RouteNames.editProfile:
        return _build(const EditProfileScreen());

      case RouteNames.changePassword:
        return _build(const ChangePasswordScreen());

      default:
        return _build(Scaffold(
          backgroundColor: AppColors.darkBg0,
          body: Center(child: Text('Page not found: ${settings.name}',
              style: const TextStyle(color: Colors.white))),
        ));
    }
  }

  static MaterialPageRoute _build(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
