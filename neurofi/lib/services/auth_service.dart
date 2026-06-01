import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String currency = 'INR',
    String phone = '',
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name':     name,
      'email':    email,
      'password': password,
      'currency': currency,
      'phone':    phone,
    });
    final token = response.data['data']['token'];
    await _saveToken(token);
    return UserModel.fromJson(response.data['data']['user']);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email':    email,
      'password': password,
    });
    final token = response.data['data']['token'];
    await _saveToken(token);
    return UserModel.fromJson(response.data['data']['user']);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _deleteToken();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}
