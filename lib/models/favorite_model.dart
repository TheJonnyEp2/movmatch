import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 2)
class Favorite extends HiveObject {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final int movieId;
  
  @HiveField(2)
  final DateTime likedAt;

  Favorite({
    required this.userId,
    required this.movieId,
    required this.likedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieId': movieId,
      'likedAt': likedAt.toIso8601String(),
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      userId: map['userId'] as String,
      movieId: map['movieId'] as int,
      likedAt: DateTime.parse(map['likedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Favorite{userId: $userId, movieId: $movieId, likedAt: $likedAt}';
  }
}