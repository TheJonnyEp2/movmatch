import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String passwordHash;
  
  @HiveField(3)
  final String name;
  
  @HiveField(4)
  final String surname;
  
  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  String bio;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.surname,
    required this.createdAt,
    this.bio = 'Обо мне или моих увлечениях',
  });

  bool verifyPassword(String password) {
    final hash = _hashPassword(password);
    return passwordHash == hash;
  }

  static String hashPassword(String password) {
    return _hashPassword(password);
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name $surname}';
  }
}