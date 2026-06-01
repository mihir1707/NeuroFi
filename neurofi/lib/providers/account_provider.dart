import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  List<AccountModel> _accounts = [];
  AccountModel? _selectedAccount;
  bool _isLoading = false;
  String? _errorMessage;

  List<AccountModel> get accounts => _accounts;
  AccountModel? get selectedAccount => _selectedAccount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBalance =>
      _accounts.fold(0, (sum, acc) => sum + acc.balance);

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

  Future<void> loadAccounts({bool includeArchived = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      _accounts = await _accountService.getAccounts(
        includeArchived: includeArchived,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAccountById(String accountId) async {
    _setLoading(true);
    try {
      _selectedAccount = await _accountService.getAccountById(accountId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAccount({
    required String name,
    required String type,
    required double balance,
    String currency = 'INR',
    String institution = '',
    String accountNumberLast4 = '',
    String icon = '🏦',
    String color = '#3B82F6',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newAccount = await _accountService.createAccount(
        name:               name,
        type:               type,
        balance:            balance,
        currency:           currency,
        institution:        institution,
        accountNumberLast4: accountNumberLast4,
        icon:               icon,
        color:              color,
      );
      _accounts.insert(0, newAccount);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAccount(String accountId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _accountService.updateAccount(accountId, updates);
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index != -1) _accounts[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _accountService.deleteAccount(accountId);
      _accounts.removeWhere((a) => a.id == accountId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void selectAccount(AccountModel account) {
    _selectedAccount = account;
    notifyListeners();
  }
}
