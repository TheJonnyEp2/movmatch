import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../database/favorite_database.dart';
import '../models/movie_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      authProvider.saveCurrentRoute('/profile');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (!authProvider.isAuthenticated || currentUser == null) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Загрузка профиля...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(activeTab: 'profile'),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _ProfileHeader(
                user: currentUser,
                key: ValueKey(currentUser.id),
              ),
            ),
            Expanded(child: _LikedMovies()),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatefulWidget {
  final User? user;

  const _ProfileHeader({super.key, this.user});

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  bool _isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.user?.bio ??
        'Обо мне или моих увлечениях';
  }

  @override
  void didUpdateWidget(covariant _ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != null && widget.user != oldWidget.user) {
      _bioController.text = widget.user!.bio;
      _isEditingBio = false;
      _isSaving = false;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveBio() async {
    if (_bioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Описание не может быть пустым'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateBio(_bioController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Описание обновлено'),
          backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() {
        _isEditingBio = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditingBio = false;
      _bioController.text = widget.user?.bio ??
        'Обо мне или моих увлечениях';
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        widget.user != null ? '${widget.user!.name} ${widget.user!.surname}' : 'Гость';
    final userEmail = widget.user?.email ?? 'отсутствует';
    final currentBio = widget.user?.bio ??
      'Обо мне или моих увлечениях';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color.fromRGBO(210, 112, 255, 0.2),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color.fromRGBO(210, 112, 255, 1),
                ),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.user != null) ...[
                const SizedBox(width: 20),
                FutureBuilder<int>(
                  future: FavoriteDatabase.instance.getUserLikesCount(widget.user!.id),
                  builder: (context, snapshot) {
                    final likesCount = snapshot.data ?? 0;
                    return _Stat(likesCount.toString(), 'Понравилось');
                  },
                ),
                _Stat('56', 'Совпадений'),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _isEditingBio
                    ? TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        minLines: 2,
                        maxLength: 200,
                        style: const TextStyle(
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color.fromRGBO(210, 112, 255, 0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color.fromRGBO(210, 112, 255, 1)),
                          ),
                          filled: true,
                          fillColor: Colors.grey[900],
                          hintText: 'Расскажите о себе...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          counterStyle: const TextStyle(color: Colors.grey),
                        ),
                        textInputAction: TextInputAction.newline,
                      )
                    : Text(
                        currentBio,
                        style: const TextStyle(
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              if (widget.user != null)
                Column(
                  children: [
                    if (_isEditingBio)
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _isSaving ? null : _saveBio,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                              tooltip: 'Сохранить',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _cancelEditing,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: 'Отменить',
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(210, 112, 255, 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingBio = true;
                            });
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Редактировать описание',
                        ),
                      ),
                  ],
                ),
            ],
          ),
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
              color: Color.fromARGB(255, 161, 161, 161),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Onest',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 80, 80, 80),
            ),
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

      final likedMovies =
          await FavoriteDatabase.instance.getUserLikedMovies(currentUser.id);

      setState(() {
        _movies = likedMovies;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки фильмов: $e';
        _isLoading = false;
      });
    }
  }

  void _removeMovieFromList(int movieId) {
    setState(() {
      _movies.removeWhere((movie) => movie.id == movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Понравившиеся фильмы',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CyGrotesk',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(210, 112, 255, 1),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMovies,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Повторить',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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

    return Padding(
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
          return _MovieGridCard(
            movie: movie,
            onMovieRemoved: () => _removeMovieFromList(movie.id),
          );
        },
      ),
    );
  }
}

class _MovieGridCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onMovieRemoved;

  const _MovieGridCard({
    required this.movie,
    this.onMovieRemoved,
  });

  @override
  State<_MovieGridCard> createState() => _MovieGridCardState();
}

class _MovieGridCardState extends State<_MovieGridCard> {
  bool _isRemoving = false;

  Future<void> _removeFromFavorites() async {
    try {
      setState(() {
        _isRemoving = true;
      });

      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        await FavoriteDatabase.instance.removeFromLiked(
          currentUser.id,
          widget.movie.id,
        );

        widget.onMovieRemoved?.call();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка удаления: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRemoving = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
        title: const Text(
          'Удалить из понравившихся?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Вы уверены, что хотите удалить "${widget.movie.title}" из понравившихся?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromFavorites();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
            ),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
        child: Stack(
          children: [
            Column(
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
                      widget.movie.imageUrl,
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
                        widget.movie.title,
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
                        widget.movie.description.length > 100
                            ? '${widget.movie.description.substring(0, 100)}...'
                            : widget.movie.description,
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
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _isRemoving ? null : _showDeleteConfirmation,
                  icon: _isRemoving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'Удалить из понравившихся',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}