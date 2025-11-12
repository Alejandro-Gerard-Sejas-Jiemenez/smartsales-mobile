class Category {
  final int id;
  final String nombre;
  final bool estado;
  final String? fechaCreacion;

  Category({
    required this.id,
    required this.nombre,
    required this.estado,
    this.fechaCreacion,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      estado: json['estado'] ?? true,
      fechaCreacion: json['fecha_creacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
      'fecha_creacion': fechaCreacion,
    };
  }
}
