import 'dart:convert'; // Para trabajar con JSON
import 'package:dio/dio.dart';
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/movies/data/models/movie.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoriteDataSource {
  Future<MovieModel?> getFavoriteMovie(String movieId);
}

class FavoriteDataSourceImpl implements FavoriteDataSource {
  final DioClient dioClient;

  FavoriteDataSourceImpl(this.dioClient);

  @override
  Future<MovieModel?> getFavoriteMovie(String movieId) async {
    try {
      // Intentar obtener los datos desde la API
      final response = await dioClient.get('/movie/$movieId');

      if (response.data != null) {
        final movie = MovieModel.fromJson(response.data);

        return movie;
      } else {
        throw Exception('No data found for the movie with ID: $movieId');
      }
    } on DioException catch (_) {
      // Si ocurre un error relacionado con Dio, buscar en el caché
      return _getMovieFromCache(movieId);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Obtener una película del caché por su ID
  Future<MovieModel?> _getMovieFromCache(String movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedMovies = prefs.getString('cachedMovies');

    if (cachedMovies != null) {
      final List<dynamic> jsonList = json.decode(cachedMovies);
      final movies = jsonList.map((json) => MovieModel.fromJson(json)).toList();

      try {
        final movie = movies.firstWhere(
          (movie) => movie.id.toString() == movieId,
        );
        return movie;
      } catch (e) {
        // Si no se encuentra la película en el caché, devolver null
        return null;
      }
    } else {
      // Si no hay caché disponible, devolver null
      return null;
    }
  }
}
