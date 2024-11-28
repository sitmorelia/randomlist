// lib/features/movies/domain/repositories/movie.repository.interface.dart
import 'package:random_list/features/movies/domain/entities/movie.dart';

abstract class FavoriteRepository {
  Future<Movie> getFavoriteMovie(String movieId);
}
