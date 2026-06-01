import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  List<BudgetModel> _budgets = [];
  BudgetModel? _selectedBudget;
  bool _isLoading = false;
  String? _errorMessage;

  List<BudgetModel> get budgets => _budgets;
  BudgetModel? get selectedBudget => _selectedBudget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BudgetModel> get exceededBudgets =>
      _budgets.where((b) => b.isExceeded).toList();

  List<BudgetModel> get warningBudgets =>
      _budgets.where((b) => b.isWarning).toList();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadBudgets({bool? isActive, String? period}) async {
    _setLoading(true);
    _setError(null);
    try {
      _budgets = await _budgetService.getBudgets(
        isActive: isActive,
        period:   period,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActiveBudgets() async {
    await loadBudgets(isActive: true);
  }

  Future<void> loadBudgetById(String budgetId) async {
    _setLoading(true);
    try {
      _selectedBudget = await _budgetService.getBudgetById(budgetId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBudget({
    required String categoryId,
    required double amount,
    String currency = 'INR',
    String period = 'monthly',
    int alertThreshold = 80,
    required String startDate,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newBudget = await _budgetService.createBudget(
        categoryId:     categoryId,
        amount:         amount,
        currency:       currency,
        period:         period,
        alertThreshold: alertThreshold,
        startDate:      startDate,
      );
      _budgets.insert(0, newBudget);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBudget(String budgetId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _budgetService.updateBudget(budgetId, updates);
      final index = _budgets.indexWhere((b) => b.id == budgetId);
      if (index != -1) _budgets[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteBudget(String budgetId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _budgetService.deleteBudget(budgetId);
      _budgets.removeWhere((b) => b.id == budgetId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
