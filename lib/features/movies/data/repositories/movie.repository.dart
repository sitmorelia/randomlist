import 'package:random_list/features/movies/data/datasources/movie.datasource.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:random_list/features/movies/domain/repositories/movie.repository.interface.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieDataSource dataSource;

  MovieRepositoryImpl(this.dataSource);

  @override
  Future<List<Movie>> getMovies(int page) async {
    try {
      final models = await dataSource.getMovies(page);
      // Validar que la lista no sea nula ni vacía
      if (models == null || models.isEmpty) {
        throw Exception('No se encontraron películas para la página $page');
      }
      return models
          .map((model) => Movie(
                title: model.title,
                posterPath: model.posterPath,
                genreIds: model.genreIds,
                id: model.id,
                overview: model.overview,
                voteAverage: model.voteAverage,
              ))
          .toList();
    } catch (e) {
      return []; // Devolver una lista vacía en caso de error
    }
  }
}
