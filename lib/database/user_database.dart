import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Box<User>? _userBox;

  UserDatabase._init();

  Future<Box<User>> get box async {
    if (_userBox != null) return _userBox!;
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserAdapter());
    }

    _userBox = await Hive.openBox<User>('users_box');
    return _userBox!;
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final box = await this.box;
      final normalizedEmail = email.toLowerCase().trim();
      
      for (final user in box.values) {
        if (user.email == normalizedEmail) {
          return user;
        }
      }
      
      return null; // Пользователь не найден
    } catch (e) {
      print('Ошибка поиска пользователя: $e');
      return null;
    }
  }

  Future<User?> createUser({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      final box = await this.box;
      
      final existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Пользователь с таким email уже существует');
      }
      
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = User(
        id: userId,
        email: email.toLowerCase().trim(),
        passwordHash: User.hashPassword(password),
        name: name.trim(),
        surname: surname.trim(),
        createdAt: DateTime.now(),
      );
      
      await box.put(userId, user);
      return user;
    } catch (e) {
      print('Ошибка создания пользователя: $e');
      rethrow;
    }
  }

  Future<User?> authenticateUser(String email, String password) async {
    try {
      final user = await getUserByEmail(email);
      
      if (user == null) {
        return null;
      }
      
      if (user.verifyPassword(password)) {
        return user;
      }
      
      return null;
    } catch (e) {
      print('Ошибка аутентификации: $e');
      return null;
    }
  }

  // Получить всех пользователей (для отладки)
  Future<List<User>> getAllUsers() async {
    try {
      final box = await this.box;
      return box.values.toList();
    } catch (e) {
      print('Ошибка получения пользователей: $e');
      return [];
    }
  }

  // Получить пользователя по ID
  Future<User?> getUserById(String id) async {
    try {
      final box = await this.box;
      return box.get(id);
    } catch (e) {
      print('Ошибка получения пользователя: $e');
      return null;
    }
  }

  // Обновить пользователя
  Future<void> updateUser(User user) async {
    try {
      final box = await this.box;
      await box.put(user.id, user);
    } catch (e) {
      print('Ошибка обновления пользователя: $e');
      rethrow;
    }
  }

  // Удалить пользователя
  Future<void> deleteUser(String id) async {
    try {
      final box = await this.box;
      await box.delete(id);
    } catch (e) {
      print('Ошибка удаления пользователя: $e');
      rethrow;
    }
  }

  // Получить количество пользователей
  Future<int> getUserCount() async {
    try {
      final box = await this.box;
      return box.length;
    } catch (e) {
      print('Ошибка получения количества пользователей: $e');
      return 0;
    }
  }

  // Очистить базу данных пользователей
  Future<void> clearDatabase() async {
    try {
      final box = await this.box;
      await box.clear();
    } catch (e) {
      print('Ошибка очистки базы данных: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_userBox != null && _userBox!.isOpen) {
      await _userBox!.close();
      _userBox = null;
    }
  }
}