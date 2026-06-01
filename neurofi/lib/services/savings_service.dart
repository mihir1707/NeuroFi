import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/savings_goal_model.dart';

class SavingsService {
  final Dio _dio = DioClient.instance;

  Future<List<SavingsGoalModel>> getSavingsGoals({String? status}) async {
    final response = await _dio.get('/savings', queryParameters: {
      if (status != null) 'status': status,
    });
    final List data = response.data['data'];
    return data.map((item) => SavingsGoalModel.fromJson(item)).toList();
  }

  Future<List<SavingsGoalModel>> getActiveGoals() async {
    return getSavingsGoals(status: 'active');
  }

  Future<SavingsGoalModel> getGoalById(String goalId) async {
    final response = await _dio.get('/savings/$goalId');
    return SavingsGoalModel.fromJson(response.data['data']);
  }

  Future<SavingsGoalModel> createGoal({
    required String name,
    required double targetAmount,
    String currency = 'INR',
    String description = '',
    String? targetDate,
    String icon = '🎯',
    String color = '#6366F1',
  }) async {
    final response = await _dio.post('/savings', data: {
      'name':         name,
      'targetAmount': targetAmount,
      'currency':     currency,
      'description':  description,
      'icon':         icon,
      'color':        color,
      if (targetDate != null) 'targetDate': targetDate,
    });
    final goalData = response.data['data']['goal'] ?? response.data['data'];
    return SavingsGoalModel.fromJson(goalData);
  }

  Future<SavingsGoalModel> depositToGoal({
    required String goalId,
    required double amount,
    String notes = '',
  }) async {
    final response = await _dio.patch('/savings/$goalId/deposit', data: {
      'amount': amount,
      'notes':  notes,
    });
    return SavingsGoalModel.fromJson(response.data['data']);
  }

  Future<SavingsGoalModel> updateGoal(String goalId, Map<String, dynamic> updates) async {
    final response = await _dio.patch('/savings/$goalId', data: updates);
    return SavingsGoalModel.fromJson(response.data['data']);
  }

  Future<void> deleteGoal(String goalId) async {
    await _dio.delete('/savings/$goalId');
  }
}
