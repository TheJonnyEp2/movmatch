import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
              ),
              const SizedBox(height: 8),
              const Text(
                'MovMatch',
                style: TextStyle(
                  fontFamily: 'CyGrotesk',
                  fontSize: 37.4,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(221, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 128),
              
              GradientButton(
                width: 217.0,
                height: 49.0,
                text: 'Вход',
                onPressed: () {
                  // Используем именованную маршрутизацию
                  Navigator.pushNamed(context, '/login');
                },
              ),
              const SizedBox(height: 20),
              
              GradientButton(
                width: 217.0,
                height: 49.0,
                text: 'Регистрация',
                onPressed: () {
                  // Используем именованную маршрутизацию
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}