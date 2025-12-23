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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<AuthProvider> _authProviderFuture;

  @override
  void initState() {
    super.initState();
    _authProviderFuture = _initializeAuthProvider();
  }

  Future<AuthProvider> _initializeAuthProvider() async {
    final provider = AuthProvider();
    await provider.initialize();
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthProvider>(
      future: _authProviderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'Загрузка...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
              body: Center(
                child: Text(
                  'Ошибка: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }

        final authProvider = snapshot.data!;
        
        return ChangeNotifierProvider.value(
          value: authProvider,
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
                routes: {
                  '/': (context) => _buildHomeScreen(authProvider),
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
                onUnknownRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => _buildHomeScreen(authProvider),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  static Widget _buildHomeScreen(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return const StartScreen();
    }
    
    switch (authProvider.currentRoute) {
      case '/profile':
        return const ProfileScreen();
      case '/chats':
        return const ChatsScreen();
      case '/cards':
      default:
        return const CardScreen();
    }
  }
  
  static Widget _protectedRoute(Widget screen, BuildContext context, bool isAuthenticated) {
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
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
                'Перенаправление на вход...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    
    return screen;
  }
}