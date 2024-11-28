import 'package:random_list/features/movies/data/datasources/category.datasource.dart';
import 'package:random_list/features/movies/domain/entities/category.dart';
import 'package:random_list/features/movies/domain/repositories/category.repository.interface.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDataSource dataSource;

  CategoryRepositoryImpl(this.dataSource);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final models = await dataSource.getCategories();
      // Validar que la lista no sea nula
      if (models == null) {
        throw Exception('La lista de categorías es nula');
      }
      return models
          .map((model) => Category(id: model.id, name: model.name))
          .toList();
    } catch (e) {
      return []; // Devolver lista vacía en caso de error
    }
  }
}
