import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import '../providers/auth_provider.dart';
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
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Загружаем фильмы из БД
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
        _errorMessage = '';
      });
      
      print('Загружено ${_movies.length} фильмов');
    } catch (e) {
      print('Ошибка: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки данных: $e';
      });
    }
  }

  void _onSwiped() {
    setState(() {
      if (_currentMovieIndex < _movies.length - 1) {
        _currentMovieIndex++;
      } else {
        _currentMovieIndex = 0;
      }
    });
  }

  void _reloadData() async {
    setState(() {
      _isLoading = true;
      _currentMovieIndex = 0;
    });
    
    await _initializeData();
  }
/*
  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(activeTab: 'cards'),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildContent(),
                  
                  const SizedBox(height: 30),

                  if (_movies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Text(
                          '${_currentMovieIndex + 1}/${_movies.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        height: 437,
        width: 326,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Загрузка фильмов...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Container(
        height: 437,
        width: 326,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _reloadData,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }
    
    return FlipCardWidget(
      key: ValueKey(_currentMovieIndex),
      imageUrl: _movies[_currentMovieIndex].imageUrl,
      title: _movies[_currentMovieIndex].title,
      description: _movies[_currentMovieIndex].description,
      onSwiped: _onSwiped,
      width: 326,
      height: 437,
    );
  }

  @override
  void dispose() {
    MovieDatabase.instance.close();
    super.dispose();
  }
}