import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];
  TransactionModel? _selectedTransaction;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  String? _filterType;
  String? _filterAccountId;
  String? _filterCategoryId;
  String? _searchQuery;
  String? _startDate;
  String? _endDate;

  List<TransactionModel> get transactions => _transactions;
  TransactionModel? get selectedTransaction => _selectedTransaction;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
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

  void setFilter({
    String? type,
    String? accountId,
    String? categoryId,
    String? search,
    String? startDate,
    String? endDate,
  }) {
    _filterType       = type;
    _filterAccountId  = accountId;
    _filterCategoryId = categoryId;
    _searchQuery      = search;
    _startDate        = startDate;
    _endDate          = endDate;
    loadTransactions();
  }

  void clearFilters() {
    _filterType       = null;
    _filterAccountId  = null;
    _filterCategoryId = null;
    _searchQuery      = null;
    _startDate        = null;
    _endDate          = null;
    loadTransactions();
  }

  Future<void> loadTransactions({int page = 1, int limit = 20}) async {
    _setLoading(true);
    _setError(null);
    try {
      _transactions = await _transactionService.getTransactions(
        page:       page,
        limit:      limit,
        type:       _filterType,
        accountId:  _filterAccountId,
        categoryId: _filterCategoryId,
        search:     _searchQuery,
        startDate:  _startDate,
        endDate:    _endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTransactionById(String id) async {
    _setLoading(true);
    try {
      _selectedTransaction = await _transactionService.getTransactionById(id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTransaction({
    required String accountId,
    required String type,
    required double amount,
    required String transactionDate,
    String currency = 'INR',
    String description = '',
    String notes = '',
    String? categoryId,
    List<String> tags = const [],
    bool isRecurring = false,
    String? recurrenceInterval,
    bool useAICategory = true,
  }) async {
    _isCreating = true;
    _setError(null);
    notifyListeners();
    try {
      final newTx = await _transactionService.createTransaction(
        accountId:          accountId,
        type:               type,
        amount:             amount,
        transactionDate:    transactionDate,
        currency:           currency,
        description:        description,
        notes:              notes,
        categoryId:         categoryId,
        tags:               tags,
        isRecurring:        isRecurring,
        recurrenceInterval: recurrenceInterval,
        useAICategory:      useAICategory,
      );
      _transactions.insert(0, newTx);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _transactionService.updateTransaction(id, updates);
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) _transactions[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _transactionService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
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
