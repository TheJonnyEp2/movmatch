import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/start_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/card_screen.dart';
import 'database/movie_database.dart';
import 'models/movie_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();

  Hive.registerAdapter(MovieAdapter());
  
  try {
    await MovieDatabase.instance.box; // Это инициализирует бокс
    print('Hive database initialized');
  } catch (e) {
    print('Hive initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovMatch',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/cards': (context) => const CardScreen(),
      },
    );
  }
}