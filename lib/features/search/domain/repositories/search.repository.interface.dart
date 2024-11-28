// lib/features/movies/domain/repositories/movie.repository.interface.dart
import 'package:random_list/features/movies/domain/entities/movie.dart';

abstract class SearchRepository {
  Future<List<Movie>> searchMovies(String query);
}
