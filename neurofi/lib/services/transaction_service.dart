import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final Dio _dio = DioClient.instance;

  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? accountId,
    String? categoryId,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {
      'page':  page,
      'limit': limit,
      if (type != null)       'type':      type,
      if (accountId != null)  'account':   accountId,
      if (categoryId != null) 'category':  categoryId,
      if (search != null)     'search':    search,
      if (startDate != null)  'startDate': startDate,
      if (endDate != null)    'endDate':   endDate,
    };
    final response = await _dio.get('/transactions', queryParameters: params);
    final List data = response.data['data'];
    return data.map((item) => TransactionModel.fromJson(item)).toList();
  }

  Future<TransactionModel> getTransactionById(String id) async {
    final response = await _dio.get('/transactions/$id');
    return TransactionModel.fromJson(response.data['data']);
  }

  Future<TransactionModel> createTransaction({
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
    final response = await _dio.post('/transactions', data: {
      'account':         accountId,
      'type':            type,
      'amount':          amount,
      'currency':        currency,
      'description':     description,
      'notes':           notes,
      'tags':            tags,
      'transactionDate': transactionDate,
      'isRecurring':     isRecurring,
      'useAICategory':   useAICategory,
      if (categoryId != null)         'category':           categoryId,
      if (recurrenceInterval != null) 'recurrenceInterval': recurrenceInterval,
    });
    final txData = response.data['data']['transaction'] ?? response.data['data'];
    return TransactionModel.fromJson(txData);
  }

  Future<TransactionModel> updateTransaction(String id, Map<String, dynamic> updates) async {
    final response = await _dio.patch('/transactions/$id', data: updates);
    return TransactionModel.fromJson(response.data['data']);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('/transactions/$id');
  }
}
