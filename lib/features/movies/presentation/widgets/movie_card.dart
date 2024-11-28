import 'package:flutter/material.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final Function onFavoriteDeleted;

  const MovieCard(
      {super.key, required this.movie, required this.onFavoriteDeleted});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isFavorite = false; // Indica si la película es favorita o no

  @override
  void initState() {
    super.initState();

    _loadFavoriteStatus(); // Cargar el estado inicial de la película desde SharedPreferences
  }

  // Método para cargar el estado de si la película es favorita desde SharedPreferences
  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMovies =
        prefs.getStringList('favoriteMovies')?.map(int.parse).toList() ?? [];
    setState(() {
      isFavorite = favoriteMovies.contains(widget.movie.id);
    });
  }

  // Método para alternar el estado de favorito (agregar o eliminar de favoritos)
  Future<void> _toggleFavorite(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMovies =
        prefs.getStringList('favoriteMovies')?.map(int.parse).toList() ?? [];

    String message;

    if (isFavorite) {
      // Si la película ya está en favoritos, la eliminamos
      favoriteMovies.remove(widget.movie.id);
      message = 'Se eliminó "${widget.movie.title}" de favoritos';
    } else {
      // Si no está en favoritos, la agregamos
      favoriteMovies.add(widget.movie.id);
      message = 'Se agregó "${widget.movie.title}" a favoritos';
    }

    // Guardar la lista de películas favoritas actualizada en SharedPreferences
    await prefs.setStringList(
      'favoriteMovies',
      favoriteMovies.map((id) => id.toString()).toList(),
    );

    _showSnackBar(context, message); // Mostrar mensaje de confirmación

    if (isFavorite) {
      widget
          .onFavoriteDeleted(); // Llamar al callback si se eliminó de favoritos
    }

    setState(() {
      isFavorite = !isFavorite; // Alternar el estado de favorito
    });
  }

  // Método para mostrar un SnackBar con un mensaje
  void _showSnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Para llenar todo el ancho
        children: [
          Expanded(
            flex: 6, // La imagen ocupa 3 partes del espacio disponible
            child: GestureDetector(
              onTap: () {
                context.push('/detail',
                    extra: widget.movie); // Navegar a la pantalla de detalles
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(
                      12.0), // Radio para la esquina superior izquierda
                  topRight: Radius.circular(
                      12.0), // Radio para la esquina superior derecha
                ),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text('No se pudo cargar la imagen')),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2, // El título ocupa 1 parte del espacio disponible
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.movie.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // Botón del corazón con toggle para agregar o eliminar de favoritos
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(
                            context), // Llamar al método para alternar el estado
                      ),

                      // Botón de compartir
                      IconButton(
                        icon: const Icon(Icons.share),
                        padding: EdgeInsets.zero,
                        onPressed: () => _showSnackBar(
                            context, "Se compartió ${widget.movie.title}"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
