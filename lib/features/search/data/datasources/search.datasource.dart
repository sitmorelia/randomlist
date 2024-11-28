import 'dart:convert'; // Para trabajar con JSON
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/movies/data/models/movie.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchDataSource {
  Future<List<MovieModel>> searchMovies(String query);
}

class SearchDataSourceImpl implements SearchDataSource {
  final DioClient dioClient;

  // Constructor que recibe un DioClient
  SearchDataSourceImpl(this.dioClient);

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      // Intentar obtener los datos desde la API
      final response = await dioClient.get(
        '/search/movie',
        queryParameters: {'query': query},
      );

      // Verificar si la respuesta tiene los datos esperados
      if (response.statusCode == 200 && response.data != null) {
        final List<MovieModel> movies = _parseMovies(response.data);

        // Almacenar el término de búsqueda actual y los resultados en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastSearch', query); // Guardar la búsqueda
        await prefs.setString('cachedMovies',
            json.encode(response.data['results'])); // Guardar los resultados

        return movies;
      } else {
        // Manejo de errores: si la respuesta no es satisfactoria
        throw Exception('Error al obtener los resultados de la búsqueda');
      }
    } catch (e) {
      // Si ocurre un error, intentar buscar en el caché
      return await _searchMoviesInCache(query);
    }
  }

  // Función para convertir los resultados de la respuesta en MovieModel
  List<MovieModel> _parseMovies(Map<String, dynamic> data) {
    try {
      final List<MovieModel> movies = (data['results'] as List)
          .map((movie) => MovieModel.fromJson(movie))
          .toList();
      return movies;
    } catch (e) {
      throw Exception('Error al parsear los resultados: ${e.toString()}');
    }
  }

  // Buscar las películas en el caché basadas en el último término de búsqueda
  Future<List<MovieModel>> _searchMoviesInCache(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedMovies = prefs.getString('cachedMovies');
    final lastSearch = prefs.getString('lastSearch');

    // Si hay una búsqueda anterior y hay caché disponible
    if (lastSearch != null && cachedMovies != null) {
      // Compara la búsqueda actual con la última búsqueda
      if (query == lastSearch) {
        // Si el término de búsqueda es el mismo, devolver las películas en caché
        final List<dynamic> jsonList = json.decode(cachedMovies);
        final movies =
            jsonList.map((json) => MovieModel.fromJson(json)).toList();
        return movies;
      } else {
        // Si la búsqueda no coincide con la última, devolver una lista vacía o manejarlo como desees
        return [];
      }
    } else {
      // Si no hay caché disponible o no hay última búsqueda, devolver una lista vacía
      return [];
    }
  }
}
