import 'package:flutter/material.dart';
import '../widgets/text_field.dart';
import '../widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordconfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _nameController.dispose();
    _subnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordconfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Регистрация',
                style: TextStyle(
                  fontFamily: 'CyGrotesk',
                  fontSize: 37.4,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(221, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 70),
              
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Имя',
                      width: 217.0,
                      height: 49.0,
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _subnameController,
                      labelText: 'Фамилия',
                      width: 217.0,
                      height: 49.0,
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      width: 217.0,
                      height: 49.0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Неверный формат email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        print('Email изменён: $value');
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Пароль',
                      width: 217.0,
                      height: 49.0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен быть не менее 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    CustomTextField(
                      controller: _passwordconfirmController,
                      labelText: 'Подвердите пароль',
                      width: 217.0,
                      height: 49.0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Подтвердите пароль';
                        }
                        if (value != _passwordController.text) {
                          return 'Пароли не совпадают';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        print('Email изменён: $value');
                      },
                    ),
                    const SizedBox(height: 128),

                    GradientButton(
                      width: 217.0,
                      height: 49.0,
                      text: 'Вход',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context, '/cards');
                          }
                        }
                      ),
                    
                    const SizedBox(height: 20),
                    
                    TextButton(
                      child: const Text(
                        'Уже есть аккаунт? Войдите',
                        style: TextStyle(color: Color.fromRGBO(210, 112, 255, 1)),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}