import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:random_list/app/app.dart';
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/favorities/data/datasources/favorite.datasource.dart';
import 'package:random_list/features/favorities/data/repositories/favorite.repository.dart';
import 'package:random_list/features/favorities/domain/repositories/favorite.repository.interface.dart';
import 'package:random_list/features/favorities/domain/usecases/get_favorite_movie.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:random_list/features/movies/presentation/widgets/movie_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritiesPage extends StatefulWidget {
  const FavoritiesPage({super.key});

  @override
  State<FavoritiesPage> createState() => _FavoritiesPageState();
}

class _FavoritiesPageState extends State<FavoritiesPage> {
  late final FavoriteRepository favoriteRepository;
  late final FavoriteMovie favoriteMovie;
  late Future<List<Movie>> _favoriteMovies;
  String? _errorMessage; // Para almacenar el mensaje de error

  @override
  void initState() {
    super.initState();
    Dio dio = Dio();
    DioClient dioClient = DioClient(dio);

    FavoriteDataSource favoriteDataSource = FavoriteDataSourceImpl(dioClient);
    favoriteRepository = FavoriteRepositoryImpl(favoriteDataSource);
    favoriteMovie = FavoriteMovie(favoriteRepository);

    _favoriteMovies = _loadFavoriteMovies();
  }

  // Método para cargar las películas favoritas
  Future<List<Movie>> _loadFavoriteMovies() async {
    final favoriteIds = await getFavoriteMovieIds();
    List<Movie> movies = [];
    List<String> errors = []; // Para almacenar posibles errores

    for (int id in favoriteIds) {
      try {
        final movie = await favoriteMovie.execute(id.toString());
        if (movie != null) {
          movies.add(movie);
        }
      } catch (e) {
        // Capturamos errores específicos
        if (e is DioException) {
          errors.add('Error de red al obtener la película con ID $id');
        } else {
          errors.add('Error al cargar la película con ID $id');
        }
      }
    }

    if (errors.isNotEmpty) {
      setState(() {
        _errorMessage = errors.join('\n'); // Unir los errores y mostrarlos
      });
    }

    return movies;
  }

  // Método para actualizar la lista de películas favoritas
  void _updateFavoriteList() async {
    final updatedMovies = await _loadFavoriteMovies();
    setState(() {
      _favoriteMovies = Future.value(updatedMovies); // Actualizar el Future
    });
  }

  // Obtener los IDs de las películas favoritas desde SharedPreferences
  Future<List<int>> getFavoriteMovieIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteIdsString =
        prefs.getStringList('favoriteMovies');

    if (favoriteIdsString != null) {
      return favoriteIdsString.map((id) => int.parse(id)).toList();
    }
    return []; // Devuelve una lista vacía si no hay favoritos guardados
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculamos cuántas columnas caben basándonos en un ancho mínimo
    const minItemWidth = 200;
    final crossAxisCount = (screenWidth / minItemWidth).floor().clamp(1, 10);

    return Scaffold(
      body: BasePage(
        body: FutureBuilder<List<Movie>>(
          future: _favoriteMovies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar las películas'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tienes películas favoritas'));
            }

            // Si hay algún error, mostrarlo
            if (_errorMessage != null && _errorMessage!.isNotEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Algunas películas no se pudieron cargar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 162, 162, 162), fontSize: 16),
                ),
              );
            }

            final movies = snapshot.data!;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Dos columnas
                  crossAxisSpacing: 8.0, // Espacio horizontal
                  mainAxisSpacing: 8.0, // Espacio vertical
                  childAspectRatio: 0.6, // Relación ancho:alto de cada tarjeta
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieCard(
                      movie: movie, onFavoriteDeleted: _updateFavoriteList);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
