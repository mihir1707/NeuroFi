import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/ai_insight_model.dart';

class AiService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> categorize({
    required String description,
    double amount = 0,
    String? merchantName,
  }) async {
    final response = await _dio.post('/ai/categorize', data: {
      'description': description,
      'amount':      amount,
      'merchantName': ?merchantName,
    });
    return response.data['data'];
  }

  Future<List<Map<String, dynamic>>> categorizeBatch(
    List<Map<String, dynamic>> transactions,
  ) async {
    final response = await _dio.post('/ai/categorize/batch', data: {
      'transactions': transactions,
    });
    final List results = response.data['data']['results'];
    return results.cast<Map<String, dynamic>>();
  }

  Future<List<AiInsightModel>> getInsights() async {
    final response = await _dio.get('/ai/insights');
    final List insights = response.data['data']['insights'];
    return insights.map((item) => AiInsightModel.fromJson(item)).toList();
  }

  Future<List<BudgetPredictionModel>> getBudgetPredictions() async {
    final response = await _dio.get('/ai/predict-budget');
    final List predictions = response.data['data']['predictions'];
    return predictions.map((item) => BudgetPredictionModel.fromJson(item)).toList();
  }

  Future<String> chat({
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    final response = await _dio.post('/ai/chat', data: {
      'message': message,
      'history': history,
    });
    return response.data['data']['reply'] ?? '';
  }
}
