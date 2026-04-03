import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.post('/auth/login', data: {
        'phoneNumber': phoneNumber,
        'password': password,
      });

      if (response.statusCode == 200) {
        _token = response.data['token'];
        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _token!);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    notifyListeners();
  }
}
