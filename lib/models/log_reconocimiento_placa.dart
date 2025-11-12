class LogReconocimientoPlaca {
  final int id;
  final String? nombrePropietario;
  final String? apellidoPropietario;
  final String? marcaVehiculo;
  final String? modeloVehiculo;
  final String? matriculaVehiculo;
  final String? placaDetectada;
  final String? descripcion;
  final double? confianza;
  final String? fechaHora;
  final String? fotoRuta;

  LogReconocimientoPlaca({
    required this.id,
    this.nombrePropietario,
    this.apellidoPropietario,
    this.marcaVehiculo,
    this.modeloVehiculo,
    this.matriculaVehiculo,
    this.placaDetectada,
    this.descripcion,
    this.confianza,
    this.fechaHora,
    this.fotoRuta,
  });

  factory LogReconocimientoPlaca.fromJson(Map<String, dynamic> json) {
    double? parseConfianza(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return LogReconocimientoPlaca(
      id: json['id'],
      nombrePropietario: json['nombre_propietario'] ?? "",
      apellidoPropietario: json['apellido_propietario'] ?? "",
      marcaVehiculo: json['marca_vehiculo'] ?? "",
      modeloVehiculo: json['modelo_vehiculo'] ?? "",
      matriculaVehiculo: json['matricula_vehiculo'] ?? "",
      placaDetectada: json['placa_detectada'] ?? "",
      descripcion: json['descripcion'],
      confianza: parseConfianza(json['confianza']),
      fechaHora: json['fecha_hora'],
      fotoRuta: json['foto_ruta'],
    );
  }
}
