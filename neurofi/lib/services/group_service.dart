import 'package:dio/dio.dart';
import '../config/dio_client.dart';
import '../models/group_model.dart';
import '../models/group_expense_model.dart';

class GroupService {
  final Dio _dio = DioClient.instance;

  Future<List<GroupModel>> getGroups() async {
    final response = await _dio.get('/groups');
    final List data = response.data['data'];
    return data.map((item) => GroupModel.fromJson(item)).toList();
  }

  Future<GroupModel> getGroupById(String groupId) async {
    final response = await _dio.get('/groups/$groupId');
    return GroupModel.fromJson(response.data['data']);
  }

  Future<GroupModel> createGroup({
    required String name,
    String description = '',
    String currency = 'INR',
    String icon = '👥',
    String color = '#7C3AED',
  }) async {
    final response = await _dio.post('/groups', data: {
      'name':        name,
      'description': description,
      'currency':    currency,
      'icon':        icon,
      'color':       color,
    });
    return GroupModel.fromJson(response.data['data']);
  }

  Future<GroupModel> updateGroup(String groupId, Map<String, dynamic> updates) async {
    final response = await _dio.patch('/groups/$groupId', data: updates);
    return GroupModel.fromJson(response.data['data']);
  }

  Future<void> deleteGroup(String groupId) async {
    await _dio.delete('/groups/$groupId');
  }

  Future<void> addMember({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    await _dio.post('/groups/$groupId/members', data: {
      'userId': userId,
      'role':   role,
    });
  }

  Future<void> removeMember({required String groupId, required String memberId}) async {
    await _dio.delete('/groups/$groupId/members/$memberId');
  }

  Future<GroupExpenseModel> addGroupExpense({
    required String groupId,
    required String description,
    required double amount,
    String currency = 'INR',
    String category = '',
    String splitType = 'equal',
    required String expenseDate,
  }) async {
    final response = await _dio.post('/groups/$groupId/expenses', data: {
      'description': description,
      'amount':      amount,
      'currency':    currency,
      'category':    category,
      'splitType':   splitType,
      'expenseDate': expenseDate,
    });
    return GroupExpenseModel.fromJson(response.data['data']);
  }

  Future<List<GroupExpenseModel>> getGroupExpenses(String groupId) async {
    final response = await _dio.get('/groups/$groupId/expenses');
    final List data = response.data['data'];
    return data.map((item) => GroupExpenseModel.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getGroupBalances(String groupId) async {
    final response = await _dio.get('/groups/$groupId/balances');
    return response.data['data'];
  }
}
