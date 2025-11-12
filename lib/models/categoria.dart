class Categoria {
  final int id;
  final String nombre;
  final bool estado;
  final String? fechaCreacion;

  Categoria({
    required this.id,
    required this.nombre,
    required this.estado,
    this.fechaCreacion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
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
