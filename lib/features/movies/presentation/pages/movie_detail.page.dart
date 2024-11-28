import 'package:flutter/material.dart';
import 'package:random_list/features/movies/domain/entities/category.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_list/core/providers/category_providers.dart';

class MovieDetailPage extends ConsumerWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryStateProvider);

    // Obtener los nombres de las categorías de manera eficiente
    final categoryNames = movie.genreIds
        .map((id) => categories
            .firstWhere((category) => category.id == id,
                orElse: () => Category(id: id, name: 'Desconocido'))
            .name)
        .toList();

    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth <= 360
        ? screenWidth * 0.6
        : (screenWidth > 360 && screenWidth < 680)
            ? screenWidth * 0.45
            : screenWidth;

    IconData voteIcon =
        movie.voteAverage <= 5.9 ? Icons.thumb_down : Icons.thumb_up;
    int starCount = (movie.voteAverage / 2).floor();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            // Fondo con degradado
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 95, 227, 244),
                    Color.fromARGB(255, 20, 95, 199),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // AppBar con contenido
            AppBar(
              backgroundColor:
                  Colors.transparent, // Hacemos el AppBar transparente
              elevation: 0, // Eliminamos la sombra
              title: Text(
                movie.title,
                style: const TextStyle(color: Colors.white),
              ), // Mostrar el título de la película en el AppBar
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Regresar a la pantalla anterior
                  Navigator.pop(context);
                },
              ),
              centerTitle: true,
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 610) {
            // Estructura para pantallas grandes
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de la película
                Container(
                  width: imageWidth * 0.4,
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('No se pudo cargar la imagen')),
                  ),
                ),
                const SizedBox(width: 20.0),
                // Resto de la información
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30.0),
                        // Puntuación de la película
                        Row(
                          children: [
                            Icon(voteIcon, color: Colors.white),
                            const SizedBox(width: 8.0),
                            Text(
                              "${double.parse(movie.voteAverage.toStringAsFixed(1))} / 10",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        // Mostrar las estrellas
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < starCount
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.yellow,
                            );
                          }),
                        ),
                        const SizedBox(height: 30.0),
                        // Sinopsis de la película
                        const Text(
                          "Sinopsis",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 190, 234, 255)),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          movie.overview,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 30.0),
                        // Géneros de la película
                        const Text(
                          "Género",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 190, 234, 255)),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          categoryNames.join(", "),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Estructura para pantallas pequeñas
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de la película
                  Center(
                    child: Container(
                      width: imageWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            12.0), // Ajusta el radio del borde según lo necesites
                        border: Border.all(
                            color: Colors.black,
                            width: 2.0), // Agrega un borde (opcional)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            12.0), // Esto aplica el redondeo a la imagen también
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Text('No se pudo cargar la imagen'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  // Puntuación de la película
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(voteIcon, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text(
                        "${double.parse(movie.voteAverage.toStringAsFixed(1))} / 10",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // Mostrar las estrellas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < starCount ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                      );
                    }),
                  ),
                  const SizedBox(height: 30.0),
                  // Sinopsis de la película
                  const Text(
                    "Sinopsis",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 190, 234, 255)),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    movie.overview,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30.0),
                  // Géneros de la película
                  const Text(
                    "Género",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 190, 234, 255)),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    categoryNames.join(", "),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
