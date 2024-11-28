import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:random_list/app/app.dart';
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:random_list/features/movies/presentation/widgets/movie_card.dart';
import 'package:random_list/features/search/data/datasources/search.datasource.dart';
import 'package:random_list/features/search/data/repositories/search.repository.dart';
import 'package:random_list/features/search/domain/repositories/search.repository.interface.dart';
import 'package:random_list/features/search/domain/usecases/search_movies.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchRepository searchRepository;
  late final SearchMovies searchMovies;
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _results = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Configuración de los servicios
    Dio dio = Dio();
    DioClient dioClient = DioClient(dio);
    SearchDataSource searchDataSource = SearchDataSourceImpl(dioClient);
    searchRepository = SearchRepositoryImpl(searchDataSource);
    searchMovies = SearchMovies(searchRepository);

    // Recuperar la última palabra de búsqueda guardada
    _loadLastSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Cargar la última búsqueda desde SharedPreferences
  Future<void> _loadLastSearch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSearch = prefs.getString('lastSearch') ?? '';

      if (lastSearch.isNotEmpty) {
        _searchController.text = lastSearch;
        await _searchMovies(
            lastSearch); // Realizar la búsqueda automáticamente si hay un valor guardado
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar la última búsqueda: $e';
      });
    }
  }

  // Guardar la palabra de búsqueda en SharedPreferences
  Future<void> _saveSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastSearch', query);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar la búsqueda: $e';
      });
    }
  }

  // Método de búsqueda
  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      // Si la búsqueda está vacía, vaciar los resultados y registrar búsqueda vacía
      setState(() {
        _results = [];
        _errorMessage = '';
        _isLoading = false;
      });

      // Guardar búsqueda vacía en SharedPreferences
      _saveSearch('');

      return; // Salir de la función
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await searchMovies.execute(query);

      // Guardar la búsqueda no vacía en SharedPreferences
      await _saveSearch(query);

      setState(() {
        _results = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al buscar películas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculamos cuántas columnas caben basándonos en un ancho mínimo
    const minItemWidth = 200;
    final crossAxisCount = (screenWidth / minItemWidth).floor().clamp(1, 10);

    return Scaffold(
      body: BasePage(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar películas",
                    filled: true, // Hace que el fondo sea blanco
                    fillColor: Colors.white, // Color de fondo blanco
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Bordes ligeramente redondeados
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1), // Borde gris tenue
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.grey), // Icono dentro del input
                    contentPadding: const EdgeInsets.only(
                        left:
                            16.0), // Para asegurar que el texto empieza después del ícono
                  ),
                  onSubmitted: _searchMovies,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Center(
                    child: Text(_errorMessage,
                        style: const TextStyle(color: Colors.red)))
              else if (_results.isEmpty)
                const Center(child: Text('No hay resultados'))
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // Dos columnas
                      crossAxisSpacing: 8.0, // Espacio horizontal
                      mainAxisSpacing: 8.0, // Espacio vertical
                      childAspectRatio:
                          0.6, // Relación ancho:alto de cada tarjeta
                    ),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final movie = _results[index];
                      return MovieCard(
                        movie: movie,
                        onFavoriteDeleted: () => {},
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
