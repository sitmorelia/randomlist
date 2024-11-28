import 'package:random_list/features/movies/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({required int id, required String name})
      : super(id: id, name: name);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'];
      final name = json['name'];

      if (id == null || name == null) {
        throw const FormatException('Faltan campos en el JSON: "id" o "name"');
      }

      return CategoryModel(
        id: id is int ? id : int.tryParse(id.toString()) ?? 0,
        name: name is String ? name : '',
      );
    } catch (e) {
      return CategoryModel(id: 0, name: '');
    }
  }

  // Método toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Devuelve el 'id' de la categoría
      'name': name, // Devuelve el 'name' de la categoría
    };
  }
}
