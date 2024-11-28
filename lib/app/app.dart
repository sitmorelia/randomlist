import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:random_list/features/favorities/presentation/pages/favorities.page.dart';
import 'package:random_list/features/movies/domain/entities/movie.dart';
import 'package:random_list/features/movies/presentation/pages/movie_detail.page.dart';
import 'package:random_list/features/movies/presentation/pages/movies.page.dart';
import 'package:random_list/features/search/presentation/pages/search.page.dart';

/// Configuración del enrutador GoRouter
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MoviesPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/favorite',
        builder: (context, state) => const FavoritiesPage(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final movie = state.extra as Movie?;
          if (movie == null) {
            // En caso de que no se pase un objeto Movie, se puede mostrar una página de error
            return const Scaffold(
              body: Center(child: Text('Error: No se pudo cargar la película')),
            );
          }
          return MovieDetailPage(movie: movie);
        },
      ),
    ],
  );
}

/// Widget base que incluye el Drawer y el cuerpo de cada página
class BasePage extends StatelessWidget {
  final Widget body; // El contenido de la página específica

  BasePage({super.key, required this.body});

  // Mapa para asociar rutas con títulos
  Map<String, String> routeTitles = {
    '/': 'Películas',
    '/search': 'Búsqueda',
    '/favorite': 'Favoritos',
  };

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final appBarTitle = routeTitles[currentRoute] ?? 'Desconocido';

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
                appBarTitle,
                style: const TextStyle(color: Colors.white),
              ),
              centerTitle: true,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 0, 0, 0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CircleAvatar(
                  radius:
                      60, // Ajusta el radio para que el diámetro sea de 120px
                  backgroundColor:
                      Colors.black, // Color de fondo mientras carga
                  child: ClipOval(
                    child: Image.network(
                      'https://picsum.photos/200',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        // Si la imagen está cargando
                        if (loadingProgress == null) {
                          return child; // Si la imagen se ha cargado, se muestra
                        } else {
                          return const Center(
                            child:
                                CircularProgressIndicator(), // Indicador de carga
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // Si ocurre un error al cargar la imagen
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.blue, // Color de fondo del círculo
                          child: const Center(
                            child: Text(
                              'M', // Letra "M" en el centro
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            _buildDrawerItem(context, 'Películas', '/', currentRoute,
                icon: Icons.movie_outlined),
            _buildDrawerItem(context, 'Buscar', '/search', currentRoute,
                icon: Icons.search_outlined),
            _buildDrawerItem(context, 'Favoritos', '/favorite', currentRoute,
                icon: Icons.favorite_outline),
          ],
        ),
      ),
      body: body, // El contenido específico de cada página
    );
  }

  // Función auxiliar para construir cada ListTile del Drawer
  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    String route,
    String currentRoute, {
    required IconData icon, // Nuevo parámetro para el ícono
  }) {
    return ListTile(
      leading: Icon(
        icon, // Agrega el ícono
        color: currentRoute == route ? Colors.blue[700] : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: currentRoute == route ? Colors.blue[700] : null,
        ),
      ),
      onTap: () => context.go(route),
    );
  }
}
