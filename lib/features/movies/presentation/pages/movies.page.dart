import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:random_list/app/app.dart';
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/movies/data/datasources/movie.datasource.dart';
import 'package:random_list/features/movies/data/repositories/movie.repository.dart';
import 'package:random_list/features/movies/domain/entities/category.dart'
    as my_category;
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:random_list/features/movies/domain/repositories/movie.repository.interface.dart';
import 'package:random_list/features/movies/domain/usecases/get_movies.dart';
import 'package:random_list/features/movies/presentation/widgets/movie_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_list/core/providers/category_providers.dart';

class MoviesPage extends ConsumerStatefulWidget {
  const MoviesPage({super.key});

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends ConsumerState<MoviesPage> {
  late final MovieRepository movieRepository;
  late final GetMovies getMovies;

  List<Movie> allMovies = [];
  int currentPage = 3;
  late final Future<void> _initialLoadFuture;

  List<int> selectedCategory = [];
  List<Movie> filteredMovies = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    Dio dio = Dio();
    DioClient dioClient = DioClient(dio);

    MovieDataSource movieDataSource = MovieDataSourceImpl(dioClient);
    movieRepository = MovieRepositoryImpl(movieDataSource);
    getMovies = GetMovies(movieRepository);

    _initialLoadFuture = _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      allMovies.clear();
      for (int page = 1; page <= 3; page++) {
        List<Movie> movies = await getMovies.execute(page);
        allMovies.addAll(movies);
      }

      setState(() {
        filteredMovies = allMovies.take(50).toList();
      });
    } catch (e) {}
  }

  Future<void> _loadMoreMovies() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Movie> moreMovies = await getMovies.execute(currentPage + 1);
      if (moreMovies.isNotEmpty) {
        allMovies.addAll(moreMovies);
        currentPage++;

        setState(() {
          filteredMovies = selectedCategory.isEmpty
              ? allMovies
              : allMovies
                  .where((movie) =>
                      movie.genreIds.any((id) => selectedCategory.contains(id)))
                  .toList();
        });
      }
    } catch (e) {}

    setState(() {
      isLoading = false;
    });
  }

  List<my_category.Category> _getUniqueCategories(
      List<my_category.Category> categories) {
    final allCategories = allMovies
        .expand((movie) => movie.genreIds)
        .map((id) => categories.firstWhere((category) => category.id == id))
        .toSet()
        .toList();
    return allCategories;
  }

  void _filterMovies(List<int> categoryIds) {
    List<Movie> moviesTemp;

    if (categoryIds.isEmpty) {
      moviesTemp = allMovies;
    } else {
      moviesTemp = allMovies
          .where(
              (movie) => movie.genreIds.any((id) => categoryIds.contains(id)))
          .toList();
    }

    setState(() {
      filteredMovies = moviesTemp;
      selectedCategory = categoryIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculamos cuántas columnas caben basándonos en un ancho mínimo
    const minItemWidth = 200;
    final crossAxisCount = (screenWidth / minItemWidth).floor().clamp(1, 10);

    return Consumer(
      builder: (context, ref, child) {
        final categories = ref.watch(categoryStateProvider);

        if (categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final uniqueCategories = _getUniqueCategories(categories);

        return Scaffold(
          body: BasePage(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<void>(
                  future: _initialLoadFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Column(
                        children: [
                          // Chips para categorías
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                spacing: 8.0, // Espacio entre los chips
                                runSpacing: 8.0, // Espacio entre filas
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: ChoiceChip(
                                      label: const Text('Todas'),
                                      selected: selectedCategory.isEmpty,
                                      onSelected: (isSelected) {
                                        _filterMovies(
                                            []); // Mostrar todas las películas
                                      },
                                      selectedColor: const Color.fromARGB(
                                          255,
                                          195,
                                          234,
                                          255), // Color de fondo cuando está seleccionado
                                    ),
                                  ),
                                  ...uniqueCategories.map((category) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: ChoiceChip(
                                        label: Text(category.name),
                                        selected: selectedCategory
                                            .contains(category.id),
                                        onSelected: (isSelected) {
                                          _filterMovies(
                                              isSelected ? [category.id] : []);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          // Grid de películas filtradas
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 0.6,
                              ),
                              itemCount: filteredMovies.length,
                              itemBuilder: (context, index) {
                                final movie = filteredMovies[index];
                                return MovieCard(
                                  movie: movie,
                                  onFavoriteDeleted: () => {},
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: ElevatedButton(
                              onPressed: _loadMoreMovies,
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Cargar más'),
                            ),
                          )
                        ],
                      );
                    }
                  }),
            ),
          ),
        );
      },
    );
  }
}
