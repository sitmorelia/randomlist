import 'package:random_list/features/movies/domain/repositories/movie.repository.interface.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';

class GetMovies {
  final MovieRepository movieRepository;

  GetMovies(this.movieRepository);

  Future<List<Movie>> execute(int page) async {
    try {
      // Intentamos obtener las películas desde el repositorio
      return await movieRepository.getMovies(page);
    } catch (e) {
      return [];
    }
  }
}
