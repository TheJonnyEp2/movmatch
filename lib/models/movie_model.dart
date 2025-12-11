import 'package:hive/hive.dart';

part 'movie_model.g.dart'; // Генерируемый файл

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String imageUrl;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, description: ${description.substring(0, 30)}...}';
  }
}