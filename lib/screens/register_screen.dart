import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  
  @override
  void dispose() {
    _nameController.dispose();
    _subnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordconfirmController.dispose();
    super.dispose();
  }

  Future<void> _performRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.register(
          _nameController.text.trim(),
          _subnameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success) {
          //РЕГИСТРАЦИЯ - ПЕРЕНАПРАВЛЯЕМ НА /cards
          Navigator.pushReplacementNamed(context, '/cards');
        } else {
          setState(() {
            _errorMessage = 'Ошибка регистрации. Проверьте данные';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Ошибка при регистрации: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите имя';
                          }
                          if (value.length < 2) {
                            return 'Имя должно быть не менее 2 символов';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: _subnameController,
                        labelText: 'Фамилия',
                        width: 217.0,
                        height: 49.0,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите фамилию';
                          }
                          return null;
                        },
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
                          if (!AuthProvider.isValidEmail(value)) {
                            return 'Неверный формат email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Пароль',
                        obscureText: _obscurePassword,
                        suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        onSuffixPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
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
                        labelText: 'Подтвердите пароль',
                        obscureText: _obscurePasswordConfirm,
                        suffixIcon: _obscurePasswordConfirm ? Icons.visibility : Icons.visibility_off,
                        onSuffixPressed: () {
                          setState(() {
                            _obscurePasswordConfirm = !_obscurePasswordConfirm;
                          });
                        },
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
                      ),
                      
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 128),

                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : GradientButton(
                              width: 217.0,
                              height: 49.0,
                              text: 'Далее',
                              onPressed: _performRegistration,
                            ),
                      
                      const SizedBox(height: 20),
                      
                      TextButton(
                        child: const Text(
                          'Уже есть аккаунт? Войдите',
                          style: TextStyle(color: Color.fromRGBO(210, 112, 255, 1)),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/login');
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}