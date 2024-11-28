class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['id'] ?? 0, // Asigna 0 si 'id' es nulo
        name: json['name'] ?? '', // Asigna un valor vacío si 'name' es nulo
      );
    } catch (e) {
      return Category(
          id: 0,
          name:
              'Desconocido'); // Devuelve una categoría por defecto en caso de error
    }
  }
}
