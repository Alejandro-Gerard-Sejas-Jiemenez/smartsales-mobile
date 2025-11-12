class Factura {
  final int? id;
  final int residenteId;
  final String? descripcion;
  final double montoTotal;
  final String estado;
  final String? tipoFactura;
  final String? fechaCreacion;
  final String? fechaEmision;
  final String? fechaLimite;
  final String? residenteNombre;

  Factura({
    this.id,
    required this.residenteId,
    this.descripcion,
    required this.montoTotal,
    required this.estado,
    this.tipoFactura,
    this.fechaCreacion,
    this.fechaEmision,
    this.fechaLimite,
    this.residenteNombre,
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'],
      residenteId: json['residente']?['id'] ?? json['residente_id'] ?? 1,
      descripcion: json['descripcion'],
      montoTotal: _parseDouble(json['monto_total']),
      estado: json['estado'] ?? 'pendiente',
      tipoFactura: json['tipo_factura'],
      fechaCreacion: json['fecha_creacion'],
      fechaEmision: json['fecha_emision'],
      fechaLimite: json['fecha_limite'],
      residenteNombre: json['residente']?['nombre'] ?? json['residente_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'residente_id': residenteId,
      'descripcion': descripcion,
      //'monto_total': montoTotal,
      'estado': estado,
      if (tipoFactura != null) 'tipo_factura': tipoFactura,
      if (fechaLimite != null) 'fecha_limite': fechaLimite,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ConceptoPago {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double monto;
  final String tipo;

  ConceptoPago({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.monto,
    required this.tipo,
  });

  factory ConceptoPago.fromJson(Map<String, dynamic> json) {
    return ConceptoPago(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      monto: Factura._parseDouble(json['monto']),
      tipo: json['tipo'] ?? 'servicio',
    );
  }
}

class DetalleFactura {
  final int? id;
  final int facturaId;
  final int conceptoId;
  final int? reservaId;
  final double monto;
  final String? conceptoNombre;

  DetalleFactura({
    this.id,
    required this.facturaId,
    required this.conceptoId,
    this.reservaId,
    required this.monto,
    this.conceptoNombre,
  });

  factory DetalleFactura.fromJson(Map<String, dynamic> json) {
    return DetalleFactura(
      id: json['id'],
      facturaId: json['factura'],
      conceptoId: json['concepto'],
      reservaId: json['reserva'],
      monto: Factura._parseDouble(json['monto']),
      conceptoNombre: json['concepto_nombre'],
    );
  }
}
