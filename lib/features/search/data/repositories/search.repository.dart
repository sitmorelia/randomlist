// lib/features/movies/data/repositories/movie.repository.dart
import 'package:random_list/features/search/data/datasources/search.datasource.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:random_list/features/search/domain/repositories/search.repository.interface.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchDataSource dataSource;

  // Constructor que recibe la fuente de datos
  SearchRepositoryImpl(this.dataSource);

  @override
  Future<List<Movie>> searchMovies(String query) async {
    try {
      // Llamada al dataSource para obtener la lista de películas
      final movies = await dataSource.searchMovies(query);

      // Validación en caso de que no se obtengan resultados (opcional)
      if (movies.isEmpty) {
        throw Exception('No se encontraron películas para la búsqueda');
      }

      return movies;
    } catch (e) {
      // Manejo de errores: Capturamos cualquier error y lo lanzamos con un mensaje claro
      throw Exception(
          'Error en el repositorio al buscar películas: ${e.toString()}');
    }
  }
}
