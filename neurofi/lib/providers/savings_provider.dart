import 'package:flutter/material.dart';
import '../models/savings_goal_model.dart';
import '../services/savings_service.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsService _savingsService = SavingsService();

  List<SavingsGoalModel> _goals = [];
  SavingsGoalModel? _selectedGoal;
  bool _isLoading = false;
  bool _isDepositing = false;
  String? _errorMessage;

  List<SavingsGoalModel> get goals => _goals;
  SavingsGoalModel? get selectedGoal => _selectedGoal;
  bool get isLoading => _isLoading;
  bool get isDepositing => _isDepositing;
  String? get errorMessage => _errorMessage;

  List<SavingsGoalModel> get activeGoals =>
      _goals.where((g) => g.isActive).toList();

  List<SavingsGoalModel> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

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

  Future<void> loadGoals({String? status}) async {
    _setLoading(true);
    _setError(null);
    try {
      _goals = await _savingsService.getSavingsGoals(status: status);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGoalById(String goalId) async {
    _setLoading(true);
    try {
      _selectedGoal = await _savingsService.getGoalById(goalId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createGoal({
    required String name,
    required double targetAmount,
    String currency = 'INR',
    String description = '',
    String? targetDate,
    String icon = '🎯',
    String color = '#6366F1',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newGoal = await _savingsService.createGoal(
        name:          name,
        targetAmount:  targetAmount,
        currency:      currency,
        description:   description,
        targetDate:    targetDate,
        icon:          icon,
        color:         color,
      );
      _goals.insert(0, newGoal);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deposit({
    required String goalId,
    required double amount,
    String notes = '',
  }) async {
    _isDepositing = true;
    _setError(null);
    notifyListeners();
    try {
      final updated = await _savingsService.depositToGoal(
        goalId: goalId,
        amount: amount,
        notes:  notes,
      );
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) _goals[index] = updated;
      _selectedGoal = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _isDepositing = false;
      notifyListeners();
    }
  }

  Future<bool> updateGoal(String goalId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _savingsService.updateGoal(goalId, updates);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) _goals[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _savingsService.deleteGoal(goalId);
      _goals.removeWhere((g) => g.id == goalId);
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
