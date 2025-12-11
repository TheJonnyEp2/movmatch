import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userEmail;
  bool _isLoading = true;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  
  AuthProvider() {
    _loadAuthState();
  }
  
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedEmail = prefs.getString('user_email');
      
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _userEmail = savedEmail;
        _isAuthenticated = true;
        print('Состояние авторизации загружено для: $_userEmail');
      }
    } catch (e) {
      print('Ошибка загрузки состояния авторизации: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      print('Попытка входа для: $email');
      
      // Временная имитация
      await Future.delayed(const Duration(milliseconds: 800));
      
      // В реальном приложении здесь проверка с сервера
      if (email.isEmpty || password.isEmpty) {
        return false;
      }
      
      // Генерируем демо-токен
      final token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Сохраняем в локальное хранилище
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_email', email);
      
      // Обновляем состояние
      _token = token;
      _userEmail = email;
      _isAuthenticated = true;
      
      notifyListeners();
      print('Пользователь $email успешно авторизован');
      return true;
    } catch (e) {
      print('Ошибка авторизации: $e');
      return false;
    }
  }
  
  Future<bool> register(String name, String surname, String email, String password) async {
    try {
      print('Попытка регистрации для: $email');
      
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (email.isEmpty || password.isEmpty || name.isEmpty || surname.isEmpty) {
        return false;
      }
      
      return await login(email, password);
    } catch (e) {
      print('Ошибка регистрации: $e');
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      
      _token = null;
      _userEmail = null;
      _isAuthenticated = false;
      
      notifyListeners();
      print('Пользователь вышел из системы');
    } catch (e) {
      print('Ошибка при выходе: $e');
    }
  }
  
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }
}