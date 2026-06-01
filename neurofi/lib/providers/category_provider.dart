import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.isExpense).toList();

  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.isIncome).toList();

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

  Future<void> loadCategories({String? type}) async {
    _setLoading(true);
    _setError(null);
    try {
      _categories = await _categoryService.getCategories(type: type);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllCategories() async {
    await loadCategories();
  }

  Future<bool> createCategory({
    required String name,
    required String type,
    String icon = '📦',
    String color = '#64748B',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newCategory = await _categoryService.createCategory(
        name:  name,
        type:  type,
        icon:  icon,
        color: color,
      );
      _categories.add(newCategory);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _categoryService.updateCategory(categoryId, updates);
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) _categories[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _categoryService.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  CategoryModel? findById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
