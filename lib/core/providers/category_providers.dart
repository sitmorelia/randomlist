import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_list/core/network/dio_client.dart';
import 'package:random_list/features/movies/data/datasources/category.datasource.dart';
import 'package:random_list/features/movies/data/repositories/category.repository.dart';
import 'package:random_list/features/movies/domain/repositories/category.repository.interface.dart';
import 'package:random_list/features/movies/domain/usecases/get_categories.dart';
import 'package:random_list/features/movies/domain/entities/category.dart';

// Proveedor del DataSource
final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  final Dio dio = Dio();
  final dioClient = DioClient(dio);
  return CategoryDataSourceImpl(dioClient);
});

// Proveedor del Repositorio
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.read(categoryDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

// Proveedor del Caso de Uso
final getCategoriesProvider = Provider<GetCategories>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return GetCategories(repository);
});

// StateNotifier para gestionar el estado de las categorías
class CategoryStateNotifier extends StateNotifier<List<Category>> {
  final GetCategories getCategories;

  CategoryStateNotifier(this.getCategories) : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await getCategories.execute();
      state = categories;
    } catch (e) {
      // En caso de error, puedes manejarlo según tu preferencia
      state = [];
    }
  }
}

// Proveedor del StateNotifier
final categoryStateProvider =
    StateNotifierProvider<CategoryStateNotifier, List<Category>>((ref) {
  final getCategories = ref.read(getCategoriesProvider);
  return CategoryStateNotifier(getCategories);
});
