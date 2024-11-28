import 'package:random_list/features/favorities/data/datasources/favorite.datasource.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:random_list/features/favorities/domain/repositories/favorite.repository.interface.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteDataSource dataSource;

  FavoriteRepositoryImpl(this.dataSource);

  @override
  Future<Movie> getFavoriteMovie(String query) async {
    // Validar que el query no sea nulo ni vacío
    if (query.isEmpty) {
      throw Exception('Movie ID cannot be empty');
    }

    try {
      // Llamar al dataSource para obtener la película favorita
      final movie = await dataSource.getFavoriteMovie(query);

      // Si no se obtiene una película, lanzar una excepción
      if (movie == null) {
        throw Exception('Favorite movie not found for the given ID: $query');
      }

      return movie;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
