import 'dart:convert'; // Para manipular JSON
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/movies/data/models/movie.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MovieDataSource {
  Future<List<MovieModel>> getMovies(int page);
}

class MovieDataSourceImpl implements MovieDataSource {
  final DioClient dioClient;

  MovieDataSourceImpl(this.dioClient);

  @override
  Future<List<MovieModel>> getMovies(int page) async {
    try {
      // Intentamos obtener los datos de la API
      final response = await dioClient.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );

      // Verificamos si la respuesta es válida
      if (response.data != null && response.data['results'] != null) {
        final List<MovieModel> movies = (response.data['results'] as List)
            .map((movie) => MovieModel.fromJson(movie))
            .toList();

        // Guardamos los resultados en caché si la llamada fue exitosa
        _saveMoviesToCache(movies);

        return movies;
      } else {
        throw Exception('Respuesta inválida: "results" no encontrado');
      }
    } catch (e) {
      // Si hay un error en la solicitud, intentamos cargar los datos desde el caché
      return _loadMoviesFromCache();
    }
  }

  // Guardar los datos en caché
  Future<void> _saveMoviesToCache(List<MovieModel> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final moviesJson =
        json.encode(movies.map((movie) => movie.toJson()).toList());
    await prefs.setString('cachedMovies', moviesJson);
  }

  // Cargar los datos desde el caché
  Future<List<MovieModel>> _loadMoviesFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedMovies = prefs.getString('cachedMovies');

    if (cachedMovies != null) {
      final List<dynamic> jsonList = json.decode(cachedMovies);
      return jsonList.map((json) => MovieModel.fromJson(json)).toList();
    } else {
      return []; // Si no hay datos en caché, devolvemos una lista vacía
    }
  }
}
