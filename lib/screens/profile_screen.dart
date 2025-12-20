import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../database/favorite_database.dart';
import '../models/movie_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(activeTab: 'profile'),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _ProfileHeader(user: currentUser),
            ),
            Expanded(child: _LikedMovies()),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;

  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final userName = user != null ? '${user!.name} ${user!.surname}' : 'Владик Бадмаев';
    final userEmail = user?.email ?? 'email@example.com';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Onest', 
                    fontSize: 22, 
                    fontWeight: FontWeight.w600, 
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontFamily: 'Onest', 
                    fontWeight: FontWeight.w600, 
                    color: Colors.grey
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Люблю дизайнить для себя и за денежку, обожаю\nфильмы про супергероев 🍿',
                  style: TextStyle(
                    fontFamily: 'Onest', 
                    fontWeight: FontWeight.w600, 
                    color: Colors.grey
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          FutureBuilder<int>(
            future: user != null 
                ? FavoriteDatabase.instance.getUserLikesCount(user!.id)
                : Future.value(0),
            builder: (context, snapshot) {
              final likesCount = snapshot.data ?? 0;
              return _Stat(likesCount.toString(), 'Понравилось');
            },
          ),
          _Stat('56', 'Совпадений'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            value, 
            style: const TextStyle(
              fontFamily: 'Onest', 
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: Color.fromARGB(255, 161, 161, 161)
            )
          ),
          Text(
            label, 
            style: const TextStyle(
              fontFamily: 'Onest', 
              fontSize: 22, 
              fontWeight: FontWeight.w600, 
              color: Color.fromARGB(255, 80, 80, 80)
            )
          ),
        ],
      ),
    );
  }
}

class _LikedMovies extends StatefulWidget {
  @override
  State<_LikedMovies> createState() => _LikedMoviesState();
}

class _LikedMoviesState extends State<_LikedMovies> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _movies = [];
          _isLoading = false;
        });
        return;
      }
      
      final likedMovies = await FavoriteDatabase.instance
          .getUserLikedMovies(currentUser.id);
      
      setState(() {
        _movies = likedMovies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки фильмов: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Пока нет понравившихся фильмов',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cards');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Посмотреть фильмы',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text(
                'Понравившиеся фильмы (${_movies.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadMovies,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Обновить',
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.5,
              ),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return _MovieGridCard(movie: movie);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MovieGridCard extends StatelessWidget {
  final Movie movie;

  const _MovieGridCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Переход к деталям фильма
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade900,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  movie.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.movie_outlined,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CyGrotesk',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.description.length > 100 
                      ? '${movie.description.substring(0, 100)}...' 
                      : movie.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}