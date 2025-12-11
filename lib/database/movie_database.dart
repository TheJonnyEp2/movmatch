import 'package:hive/hive.dart';
import '../models/movie_model.dart';

class MovieDatabase {
  static final MovieDatabase instance = MovieDatabase._init();
  static Box<Movie>? _movieBox;

  MovieDatabase._init();

  // Инициализация Hive и открытие бокса
  Future<Box<Movie>> get box async {
    if (_movieBox != null) return _movieBox!;
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MovieAdapter());
    }

    _movieBox = await Hive.openBox<Movie>('movies_box');
    
    if (_movieBox!.isEmpty) {
      await _populateInitialData();
    }
    
    return _movieBox!;
  }

  Future<void> _populateInitialData() async {
    final movies = [
      Movie(
        id: 1,
        title: 'Интерстеллар',
        description: 'Когда засуха, пыльные бури и вымирание растений приводят человечество к продовольственному кризису, коллектив исследователей и учёных отправляется сквозь червоточину в путешествие, чтобы превзойти прежние ограничения для космических путешествий человека и найти планете с подходящими для человечества условиями.',
        imageUrl: 'assets/images/Interstellar.jpg',
      ),
      Movie(
        id: 2,
        title: 'Начало',
        description: 'Дом Кобб — искусный вор, лучший из лучших в опасном искусстве извлечения: он крадет ценные секреты из глубин подсознания во время сна, когда человеческий разум наиболее уязвим.',
        imageUrl: 'assets/images/The_begin.jpg',
      ),
      Movie(
        id: 3,
        title: 'Побег из Шоушенка',
        description: 'Бухгалтер Энди Дюфрейн обвинён в убийстве собственной жены и её любовника. Оказавшись в тюрьме под названием Шоушенк, он сталкивается с жестокостью и беззаконием, царящими по обе стороны решётки.',
        imageUrl: 'assets/images/Shawshank.jpg',
      ),
      Movie(
        id: 4,
        title: 'Крестный отец',
        description: 'Криминальная драма о сицилийской мафиозной семье Корлеоне, которую возглавляет дона Вито Корлеоне.',
        imageUrl: 'assets/images/Godfather.jpg',
      ),
      Movie(
        id: 5,
        title: 'Темный рыцарь',
        description: 'Бэтмен поднимает ставки в войне с преступностью. С помощью лейтенанта Джима Гордона и прокурора Харви Дента он намерен очистить улицы от преступности.',
        imageUrl: 'assets/images/Darkknight.jpg',
      ),
    ];

    for (var movie in movies) {
      await _movieBox!.put(movie.id, movie);
    }
    
    print('🎉 Initial data populated: ${movies.length} movies');
  }

  // Получить все фильмы
  Future<List<Movie>> getAllMovies() async {
    final box = await this.box;
    return box.values.toList();
  }

  // Получить фильм по ID
  Future<Movie?> getMovieById(int id) async {
    final box = await this.box;
    return box.get(id);
  }

  // Добавить новый фильм
  Future<int> insertMovie(Movie movie) async {
    final box = await this.box;
    await box.put(movie.id, movie);
    return movie.id;
  }

  // Обновить фильм
  Future<void> updateMovie(Movie movie) async {
    final box = await this.box;
    await box.put(movie.id, movie);
  }

  // Удалить фильм
  Future<void> deleteMovie(int id) async {
    final box = await this.box;
    await box.delete(id);
  }

  // Получить количество фильмов
  Future<int> getMovieCount() async {
    final box = await this.box;
    return box.length;
  }

  // Поиск по названию
  Future<List<Movie>> searchMovies(String query) async {
    final box = await this.box;
    return box.values
        .where((movie) => movie.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Очистить всю базу данных
  Future<void> clearDatabase() async {
    final box = await this.box;
    await box.clear();
    print('Database cleared');
  }

  // Закрыть БД
  Future<void> close() async {
    if (_movieBox != null && _movieBox!.isOpen) {
      await _movieBox!.close();
      _movieBox = null;
      print('Database closed');
    }
  }
}