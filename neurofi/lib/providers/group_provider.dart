import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/group_expense_model.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _groupService = GroupService();

  List<GroupModel> _groups = [];
  GroupModel? _selectedGroup;
  List<GroupExpenseModel> _groupExpenses = [];
  Map<String, dynamic> _balances = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<GroupModel> get groups => _groups;
  GroupModel? get selectedGroup => _selectedGroup;
  List<GroupExpenseModel> get groupExpenses => _groupExpenses;
  Map<String, dynamic> get balances => _balances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> loadGroups() async {
    _setLoading(true);
    _setError(null);
    try {
      _groups = await _groupService.getGroups();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGroupById(String groupId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _groupService.getGroupById(groupId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGroupExpenses(String groupId) async {
    _setLoading(true);
    try {
      _groupExpenses = await _groupService.getGroupExpenses(groupId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadGroupBalances(String groupId) async {
    _setLoading(true);
    try {
      _balances = await _groupService.getGroupBalances(groupId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createGroup({
    required String name,
    String description = '',
    String currency = 'INR',
    String icon = '👥',
    String color = '#7C3AED',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newGroup = await _groupService.createGroup(
        name:        name,
        description: description,
        currency:    currency,
        icon:        icon,
        color:       color,
      );
      _groups.insert(0, newGroup);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addGroupExpense({
    required String groupId,
    required String description,
    required double amount,
    String currency = 'INR',
    String category = '',
    String splitType = 'equal',
    required String expenseDate,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newExpense = await _groupService.addGroupExpense(
        groupId:     groupId,
        description: description,
        amount:      amount,
        currency:    currency,
        category:    category,
        splitType:   splitType,
        expenseDate: expenseDate,
      );
      _groupExpenses.insert(0, newExpense);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addMember({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _groupService.addMember(groupId: groupId, userId: userId, role: role);
      await loadGroupById(groupId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeMember({required String groupId, required String memberId}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _groupService.removeMember(groupId: groupId, memberId: memberId);
      await loadGroupById(groupId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _groupService.deleteGroup(groupId);
      _groups.removeWhere((g) => g.id == groupId);
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
