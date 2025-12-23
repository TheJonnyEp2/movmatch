import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/top_bar.dart';
import '../database/movie_database.dart';
import '../database/favorite_database.dart';
import '../models/movie_model.dart';
import '../providers/auth_provider.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  List<Movie> _movies = [];
  int _currentMovieIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      authProvider.saveCurrentRoute('/cards');
    });
  }

  Future<void> _initializeData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final movies = await MovieDatabase.instance.getAllMovies();

      if (movies.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Нет фильмов в базе данных';
        });
        return;
      }

      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки: $e';
      });
    }
  }

  void _onSwiped(bool isLiked) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null && isLiked) {
      final currentMovie = _movies[_currentMovieIndex];
      await FavoriteDatabase.instance.addToLiked(
        currentUser.id,
        currentMovie.id,
      );
    }

    setState(() {
      _currentMovieIndex = (_currentMovieIndex + 1) % _movies.length;
    });
  }

  void _onLikeButtonPressed() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null) {
      final currentMovie = _movies[_currentMovieIndex];
      await FavoriteDatabase.instance.addToLiked(
        currentUser.id,
        currentMovie.id,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Фильм "${currentMovie.title}" добавлен в понравившиеся'),
          backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
          duration: const Duration(seconds: 2),
        ),
      );
      
      setState(() {
        _currentMovieIndex = (_currentMovieIndex + 1) % _movies.length;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Для добавления в избранное войдите в аккаунт'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onDislikeButtonPressed() {
    setState(() {
      _currentMovieIndex = (_currentMovieIndex + 1) % _movies.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(activeTab: 'cards'),
            Expanded(
              child: Center(
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (_errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_movies.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Нет доступных фильмов',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Обновить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 800,
      height: 650,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            child: GestureDetector(
              onTap: _onDislikeButtonPressed,
              child: _SideActionButton(
                icon: Icons.close,
                color: Colors.grey,
                label: 'Пропустить',
              ),
            ),
          ),
          Positioned(
            right: 20,
            child: GestureDetector(
              onTap: _onLikeButtonPressed,
              child: _SideActionButton(
                icon: Icons.favorite,
                color: const Color.fromRGBO(210, 112, 255, 1),
                label: 'Нравится',
              ),
            ),
          ),
          FlipCardWidget(
            key: ValueKey(_currentMovieIndex),
            imageUrl: _movies[_currentMovieIndex].imageUrl,
            title: _movies[_currentMovieIndex].title,
            description: _movies[_currentMovieIndex].description,
            onSwiped: _onSwiped,
            width: 400,
            height: 650,
          ),
        ],
      ),
    );
  }
}

class _SideActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SideActionButton({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}