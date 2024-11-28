import 'dart:convert'; // Para manipular JSON
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/movies/data/models/category.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CategoryDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryDataSourceImpl implements CategoryDataSource {
  final DioClient dioClient;

  CategoryDataSourceImpl(this.dioClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      // Intentamos obtener los datos de la API
      final response = await dioClient.get('/genre/movie/list');

      // Verificamos si la respuesta es válida
      if (response.data != null && response.data['genres'] != null) {
        final List<CategoryModel> categories = (response.data['genres'] as List)
            .map((category) => CategoryModel.fromJson(category))
            .toList();

        // Guardamos los resultados en caché
        _saveCategoriesToCache(categories);

        return categories;
      } else {
        throw Exception('Respuesta inválida: "genres" no encontrado');
      }
    } catch (e) {
      // Si hay un error en la solicitud, intentamos cargar los datos desde el caché
      return _loadCategoriesFromCache();
    }
  }

  // Guardar las categorías en caché
  Future<void> _saveCategoriesToCache(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson =
        json.encode(categories.map((category) => category.toJson()).toList());
    await prefs.setString('cachedCategories', categoriesJson);
  }

  // Cargar las categorías desde el caché
  Future<List<CategoryModel>> _loadCategoriesFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCategories = prefs.getString('cachedCategories');

    if (cachedCategories != null) {
      final List<dynamic> jsonList = json.decode(cachedCategories);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      return []; // Si no hay datos en caché, devolvemos una lista vacía
    }
  }
}
