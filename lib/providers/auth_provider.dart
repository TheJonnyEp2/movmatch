import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_database.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userEmail;
  User? _currentUser;
  bool _isLoading = true;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userEmail => _userEmail;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  
  AuthProvider() {
    _loadAuthState();
  }
  
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedEmail = prefs.getString('user_email');
      
      if (savedToken != null && savedToken.isNotEmpty && savedEmail != null) {
        final user = await UserDatabase.instance.getUserByEmail(savedEmail);
        
        if (user != null) {
          _token = savedToken;
          _userEmail = savedEmail;
          _currentUser = user;
          _isAuthenticated = true;
          print('Состояние авторизации загружено для: $_userEmail');
        } else {
          await prefs.remove('auth_token');
          await prefs.remove('user_email');
        }
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
      
      final user = await UserDatabase.instance.authenticateUser(email, password);
      
      if (user == null) {
        print('Неверный email или пароль');
        return false;
      }
      
      final token = 'token_${DateTime.now().millisecondsSinceEpoch}_${user.id}';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_email', user.email);
      
      _token = token;
      _userEmail = user.email;
      _currentUser = user;
      _isAuthenticated = true;
      
      notifyListeners();
      print('Пользователь ${user.email} успешно авторизован');
      return true;
    } catch (e) {
      print('Ошибка авторизации: $e');
      return false;
    }
  }
  
  Future<bool> register(String name, String surname, String email, String password) async {
    try {
      print('Попытка регистрации для: $email');
      
      final user = await UserDatabase.instance.createUser(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );
      
      if (user == null) {
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
      _currentUser = null;
      _isAuthenticated = false;
      
      notifyListeners();
      print('Пользователь вышел из системы');
    } catch (e) {
      print('Ошибка при выходе: $e');
    }
  }
  
  Future<void> updateProfile(String name, String surname) async {
    try {
      if (_currentUser != null) {
        final updatedUser = User(
          id: _currentUser!.id,
          email: _currentUser!.email,
          passwordHash: _currentUser!.passwordHash,
          name: name,
          surname: surname,
          createdAt: _currentUser!.createdAt,
        );
        
        await UserDatabase.instance.updateUser(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
        
        print('Профиль пользователя обновлен');
      }
    } catch (e) {
      print('Ошибка обновления профиля: $e');
    }
  }
  
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> updateBio(String bio) async {
    try {
      if (_currentUser != null) {
        final updatedUser = User(
          id: _currentUser!.id,
          email: _currentUser!.email,
          passwordHash: _currentUser!.passwordHash,
          name: _currentUser!.name,
          surname: _currentUser!.surname,
          createdAt: _currentUser!.createdAt,
          bio: bio,
        );
        
        await UserDatabase.instance.updateUser(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
        
        print('Описание профиля обновлено');
      }
    } catch (e) {
      print('Ошибка обновления описания профиля: $e');
      throw e;
    }
  }
}