import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

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

  Future<bool> checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      await getMe();
    }
    notifyListeners();
    return _isLoggedIn;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String currency = 'INR',
    String phone = '',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        currency: currency,
        phone: phone,
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      // print('[Auth] Attempting login: $email');
      _user = await _authService.login(email: email, password: password);
      // print('[Auth] Login successful for: $email');
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('[Auth] Login error: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getMe() async {
    try {
      _user = await _authService.getMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadUser() => getMe();

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void updateLocalUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
