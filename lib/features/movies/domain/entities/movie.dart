class Movie {
  final String title;
  final String posterPath;
  final List<int> genreIds;
  final int id;
  final String overview;
  final double voteAverage;

  Movie({
    required this.title,
    required this.posterPath,
    required this.genreIds,
    required this.id,
    required this.overview,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    try {
      return Movie(
        title: json['title'] ?? '', // Asigna un valor vacío si 'title' es nulo
        posterPath: json['poster_path'] ??
            '', // Asigna un valor vacío si 'poster_path' es nulo
        genreIds: (json['genre_ids'] is List)
            ? List<int>.from(
                json['genre_ids']) // Si 'genre_ids' es una lista, conviértela
            : [], // Asigna una lista vacía si 'genre_ids' no es una lista válida
        id: json['id'] ?? 0, // Asigna 0 si 'id' es nulo
        overview: json['overview'] ??
            '', // Asigna un valor vacío si 'overview' es nulo
        voteAverage:
            json['vote_average'] ?? 0.0, // Asigna 0.0 si 'vote_average' es nulo
      );
    } catch (e) {
      return Movie(
        title: 'Desconocido',
        posterPath: '',
        genreIds: [],
        id: 0,
        overview: 'No disponible',
        voteAverage: 0.0,
      );
    }
  }
}
