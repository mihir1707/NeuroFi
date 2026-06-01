import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/budget_model.dart';

class BudgetService {
  final Dio _dio = DioClient.instance;

  Future<List<BudgetModel>> getBudgets({bool? isActive, String? period}) async {
    final response = await _dio.get('/budgets', queryParameters: {
      if (isActive != null) 'isActive': isActive,
      if (period != null)   'period':   period,
    });
    final List data = response.data['data'];
    return data.map((item) => BudgetModel.fromJson(item)).toList();
  }

  Future<List<BudgetModel>> getActiveBudgets() async {
    return getBudgets(isActive: true);
  }

  Future<BudgetModel> getBudgetById(String budgetId) async {
    final response = await _dio.get('/budgets/$budgetId');
    return BudgetModel.fromJson(response.data['data']);
  }

  Future<BudgetModel> createBudget({
    required String categoryId,
    required double amount,
    String currency = 'INR',
    String period = 'monthly',
    int alertThreshold = 80,
    required String startDate,
  }) async {
    final response = await _dio.post('/budgets', data: {
      'category':       categoryId,
      'amount':         amount,
      'currency':       currency,
      'period':         period,
      'alertThreshold': alertThreshold,
      'startDate':      startDate,
    });
    return BudgetModel.fromJson(response.data['data']);
  }

  Future<BudgetModel> updateBudget(String budgetId, Map<String, dynamic> updates) async {
    final response = await _dio.patch('/budgets/$budgetId', data: updates);
    return BudgetModel.fromJson(response.data['data']);
  }

  Future<void> deleteBudget(String budgetId) async {
    await _dio.delete('/budgets/$budgetId');
  }
}
