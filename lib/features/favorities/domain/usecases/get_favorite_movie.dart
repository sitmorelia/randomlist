import 'package:random_list/features/favorities/domain/repositories/favorite.repository.interface.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';

class FavoriteMovie {
  final FavoriteRepository favoriteRepository;

  FavoriteMovie(this.favoriteRepository);

  Future<Movie> execute(String query) async {
    // Validación del parámetro 'query' para asegurarse de que no esté vacío o nulo
    if (query.isEmpty) {
      throw ArgumentError('Movie ID cannot be empty');
    }

    try {
      // Llamada al repositorio para obtener la película favorita
      final movie = await favoriteRepository.getFavoriteMovie(query);

      // Si la película no es encontrada, lanzar un error personalizado
      if (movie == null) {
        throw Exception('Favorite movie not found for the given ID: $query');
      }

      return movie;
    } catch (e) {
      // Manejo de errores específicos: en este caso errores del repositorio
      if (e is ArgumentError) {
        rethrow; // Propaga el error de argumento
      } else {
        // Manejar cualquier otro tipo de error (p.ej., problemas de red, API fallida)
        throw Exception(
            'An error occurred while fetching the favorite movie: $e');
      }
    }
  }
}
