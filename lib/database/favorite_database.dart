import 'package:hive/hive.dart';
import '../models/favorite_model.dart';
import '../models/movie_model.dart';
import 'movie_database.dart';

class FavoriteDatabase {
  static final FavoriteDatabase instance = FavoriteDatabase._init();
  static Box<Favorite>? _favoriteBox;

  FavoriteDatabase._init();

  Future<Box<Favorite>> get box async {
    if (_favoriteBox != null) return _favoriteBox!;
    
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FavoriteAdapter());
    }

    _favoriteBox = await Hive.openBox<Favorite>('favorites_box');
    return _favoriteBox!;
  }

  // Добавить фильм в понравившиеся
  Future<void> addToLiked(String userId, int movieId) async {
    try {
      final box = await this.box;
      final existing = await isLiked(userId, movieId);
      
      if (!existing) {
        final favorite = Favorite(
          userId: userId,
          movieId: movieId,
          likedAt: DateTime.now(),
        );
        await box.add(favorite);
        print('Фильм $movieId добавлен в избранное пользователя $userId');
      }
    } catch (e) {
      print('Ошибка добавления в избранное: $e');
      rethrow;
    }
  }

  // Удалить из понравившихся
  Future<void> removeFromLiked(String userId, int movieId) async {
    try {
      final box = await this.box;
      final key = box.keys.firstWhere(
        (key) {
          final fav = box.get(key);
          return fav?.userId == userId && fav?.movieId == movieId;
        },
        orElse: () => -1,
      );
      
      if (key != -1) {
        await box.delete(key);
        print('Фильм $movieId удален из избранного пользователя $userId');
      }
    } catch (e) {
      print('Ошибка удаления из избранного: $e');
      rethrow;
    }
  }

  // Проверить, лайкнут ли фильм
  Future<bool> isLiked(String userId, int movieId) async {
    try {
      final box = await this.box;
      return box.values.any((fav) => 
        fav.userId == userId && fav.movieId == movieId
      );
    } catch (e) {
      print('Ошибка проверки лайка: $e');
      return false;
    }
  }

  // Получить все лайкнутые фильмы пользователя
  Future<List<Movie>> getUserLikedMovies(String userId) async {
    try {
      final box = await this.box;
      final movieDb = MovieDatabase.instance;
      
      final favoriteIds = box.values
          .where((fav) => fav.userId == userId)
          .map((fav) => fav.movieId)
          .toList();

      print('Пользователь $userId лайкнул фильмы с ID: $favoriteIds');

      final movies = <Movie>[];
      for (var id in favoriteIds) {
        final movie = await movieDb.getMovieById(id);
        if (movie != null) {
          movies.add(movie);
        }
      }
      
      print('Загружено ${movies.length} лайкнутых фильмов');
      return movies;
    } catch (e) {
      print('Ошибка получения лайкнутых фильмов: $e');
      return [];
    }
  }

  // Получить количество лайков пользователя
  Future<int> getUserLikesCount(String userId) async {
    try {
      final box = await this.box;
      return box.values.where((fav) => fav.userId == userId).length;
    } catch (e) {
      print('Ошибка получения количества лайков: $e');
      return 0;
    }
  }

  // Получить все лайки
  Future<List<Favorite>> getAllFavorites() async {
    try {
      final box = await this.box;
      return box.values.toList();
    } catch (e) {
      print('Ошибка получения всех лайков: $e');
      return [];
    }
  }

  // Очистить все лайки пользователя
  Future<void> clearUserFavorites(String userId) async {
    try {
      final box = await this.box;
      final keysToDelete = <dynamic>[];
      
      for (var key in box.keys) {
        final fav = box.get(key);
        if (fav?.userId == userId) {
          keysToDelete.add(key);
        }
      }
      
      for (var key in keysToDelete) {
        await box.delete(key);
      }
      
      print('Очищены лайки пользователя $userId');
    } catch (e) {
      print('Ошибка очистки лайков: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_favoriteBox != null && _favoriteBox!.isOpen) {
      await _favoriteBox!.close();
      _favoriteBox = null;
      print('База данных лайков закрыта');
    }
  }
}