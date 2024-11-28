import 'package:random_list/features/movies/domain/repositories/category.repository.interface.dart';
import 'package:random_list/features/movies/domain/entities/category.dart';

class GetCategories {
  final CategoryRepository categoryRepository;

  GetCategories(this.categoryRepository);

  Future<List<Category>> execute() async {
    try {
      // Intentamos obtener las categorías desde el repositorio
      return await categoryRepository.getCategories();
    } catch (e) {
      return [];
    }
  }
}
