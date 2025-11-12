class LogReconocimiento {
  final int id;
  final String? nombreResidente;
  final String? apellidoResidente;
  final String? fotoResidente;
  final String? descripcion;
  final double? coincidencia;
  final String? fechaHora;
  final String? fotoRuta;

  LogReconocimiento({
    required this.id,
    this.nombreResidente,
    this.apellidoResidente,
    this.fotoResidente,
    this.descripcion,
    this.coincidencia,
    this.fechaHora,
    this.fotoRuta,
  });

  factory LogReconocimiento.fromJson(Map<String, dynamic> json) {
    double? parseCoincidencia(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return LogReconocimiento(
      id: json['id'],
      nombreResidente: json['nombre_residente'] ?? "",
      apellidoResidente: json['apellido_residente'] ?? "",
      fotoResidente: json['foto_residente'] ?? "",
      descripcion: json['descripcion'],
      coincidencia: parseCoincidencia(json['coincidencia']),
      fechaHora: json['fecha_hora'],
      fotoRuta: json['foto_ruta'],
    );
  }
}
