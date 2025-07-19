import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.login(email, password);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _token = data['token'];
        _user = User.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['error'] ?? 'Login failed';
      }
    } catch (e) {
      _error = 'Login failed: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.register(name, email, password);
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        // Registration successful, but user is pending approval
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['error'] ?? 'Registration failed';
      }
    } catch (e) {
      _error = 'Registration failed: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
