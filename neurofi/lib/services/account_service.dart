import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/account_model.dart';

class AccountService {
  final Dio _dio = DioClient.instance;

  Future<List<AccountModel>> getAccounts({bool includeArchived = false}) async {
    final response = await _dio.get('/accounts', queryParameters: {
      'isArchived': includeArchived,
    });
    final List data = response.data['data'];
    return data.map((item) => AccountModel.fromJson(item)).toList();
  }

  Future<AccountModel> getAccountById(String accountId) async {
    final response = await _dio.get('/accounts/$accountId');
    return AccountModel.fromJson(response.data['data']);
  }

  Future<AccountModel> createAccount({
    required String name,
    required String type,
    required double balance,
    String currency = 'INR',
    String institution = '',
    String accountNumberLast4 = '',
    String icon = '🏦',
    String color = '#3B82F6',
  }) async {
    final response = await _dio.post('/accounts', data: {
      'name':               name,
      'type':               type,
      'balance':            balance,
      'currency':           currency,
      'institution':        institution,
      'accountNumberLast4': accountNumberLast4,
      'icon':               icon,
      'color':              color,
    });
    return AccountModel.fromJson(response.data['data']);
  }

  Future<AccountModel> updateAccount(String accountId, Map<String, dynamic> updates) async {
    final response = await _dio.patch('/accounts/$accountId', data: updates);
    return AccountModel.fromJson(response.data['data']);
  }

  Future<void> deleteAccount(String accountId) async {
    await _dio.delete('/accounts/$accountId');
  }

  Future<AccountModel> archiveAccount(String accountId) async {
    return await updateAccount(accountId, {'isArchived': true});
  }
}
