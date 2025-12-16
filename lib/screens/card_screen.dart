import 'package:flutter/material.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/top_bar.dart';
import '../database/movie_database.dart';
import '../models/movie_model.dart';

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

  void _onSwiped() {
    setState(() {
      _currentMovieIndex =
          (_currentMovieIndex + 1) % _movies.length;
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
      return Text(
        _errorMessage,
        style: const TextStyle(color: Colors.white),
      );
    }

    return SizedBox(
      width: 800,
      height: 650,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 0,
            child: _SideActionButton(
              icon: Icons.close,
              color: Colors.grey,
            ),
          ),
          const Positioned(
            right: 0,
            child: _SideActionButton(
              icon: Icons.favorite,
              color: Color.fromRGBO(210, 112, 255, 1),
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

  const _SideActionButton({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
