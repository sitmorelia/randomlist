import 'package:random_list/features/movies/domain/entities/movie.dart';

class MovieModel extends Movie {
  MovieModel({
    required String title,
    required String posterPath,
    required List<int> genreIds,
    required int id,
    required String overview,
    required double voteAverage,
  }) : super(
          title: title,
          posterPath: posterPath,
          genreIds: genreIds,
          id: id,
          overview: overview,
          voteAverage: voteAverage,
        );

  // Método para crear una instancia de MovieModel desde JSON
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      title: json['title'] ?? '', // Si title es nulo, asignar un valor vacío
      posterPath: json['poster_path'] ?? '',
      genreIds: (json['genre_ids'] != null && json['genre_ids'] is List)
          ? List<int>.from(
              json['genre_ids']) // Si genre_ids es una lista, convertirla
          : (json['genres'] != null && json['genres'] is List)
              ? (json['genres'] as List)
                  .map((genre) => genre['id'] as int)
                  .toList()
              : [],
      id: json['id'] ?? 0,
      overview: json['overview'] ?? '',
      voteAverage: json['vote_average'] ?? 0.0,
    );
  }

  // Método toJson para convertir MovieModel a un Map para almacenar en cache
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'poster_path': posterPath,
      'genre_ids': genreIds,
      'id': id,
      'overview': overview,
      'vote_average': voteAverage,
    };
  }
}
