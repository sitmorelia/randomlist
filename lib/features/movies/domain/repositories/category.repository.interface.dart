// lib/features/movies/domain/repositories/movie.repository.interface.dart
import 'package:random_list/features/movies/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
}
