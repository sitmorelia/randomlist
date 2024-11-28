// lib/features/movies/domain/usecases/search_movies.dart
import 'package:random_list/features/search/domain/repositories/search.repository.interface.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';

class SearchMovies {
  final SearchRepository searchRepository;

  SearchMovies(this.searchRepository);

  Future<List<Movie>> execute(String query) async {
    try {
      // Llamada al repositorio para buscar las películas
      final movies = await searchRepository.searchMovies(query);

      // Validación adicional para asegurarse de que se obtuvieron resultados
      if (movies.isEmpty) {
        throw Exception('No se encontraron películas para la búsqueda');
      }

      return movies;
    } catch (e) {
      // Manejo de errores: captura cualquier excepción y lanza una con mensaje claro
      throw Exception('Error al buscar películas: ${e.toString()}');
    }
  }
}
