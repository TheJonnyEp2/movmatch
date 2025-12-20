import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/auth_provider.dart';
import 'screens/start_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/card_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chats_screen.dart';
import 'models/movie_model.dart';
import 'models/user_model.dart';
import 'models/favorite_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive
  await Hive.initFlutter();
  
  Hive.registerAdapter(MovieAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FavoriteAdapter());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'MovMatch',
            theme: ThemeData(
              primaryColor: const Color.fromRGBO(43, 43, 43, 1),
              scaffoldBackgroundColor: const Color.fromRGBO(43, 43, 43, 1),
              fontFamily: 'Onest',
            ),
            initialRoute: '/',
            
            // Защита маршрутов
            routes: {
              '/': (context) => const StartScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/cards': (context) => _protectedRoute(
                const CardScreen(), 
                context,
                authProvider.isAuthenticated
              ),
              '/profile': (context) => _protectedRoute(
                const ProfileScreen(), 
                context,
                authProvider.isAuthenticated
              ),
              '/chats': (context) => _protectedRoute(
                const ChatsScreen(), 
                context,
                authProvider.isAuthenticated
              ),
            },
            
            // Если маршрут не найден
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const StartScreen(),
              );
            },
          );
        },
      ),
    );
  }
  
  static Widget _protectedRoute(Widget screen, BuildContext context, bool isAuthenticated) {
    if (!isAuthenticated) {
      return Builder(
        builder: (innerContext) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(innerContext).pushReplacementNamed('/login');
          });
          
          return Scaffold(
            backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Проверка авторизации...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    
    return screen;
  }
}