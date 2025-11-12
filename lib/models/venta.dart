class Venta {
  final int id;
  final String fechaVenta;
  final double totalVenta;
  final String? estado;
  final String? metodoPago;
  final int? cliente;
  final double? descuento;
  final String? notas;
  final List<DetalleVenta>? detalles;

  Venta({
    required this.id,
    required this.fechaVenta,
    required this.totalVenta,
    this.estado,
    this.metodoPago,
    this.cliente,
    this.descuento,
    this.notas,
    this.detalles,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] ?? 0,
      fechaVenta: json['fecha_venta'] ?? '',
      totalVenta: double.parse(json['total']?.toString() ?? json['total_venta']?.toString() ?? '0'),
      estado: json['estado'],
      metodoPago: json['metodo_pago'],
      cliente: json['cliente'],
      descuento: json['descuento'] != null ? double.parse(json['descuento'].toString()) : null,
      notas: json['notas'],
      detalles: json['detalles'] != null
          ? (json['detalles'] as List).map((d) => DetalleVenta.fromJson(d)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_venta': fechaVenta,
      'total_venta': totalVenta,
      'estado': estado,
      'metodo_pago': metodoPago,
      'cliente': cliente,
      'descuento': descuento,
      'notas': notas,
    };
  }
}

class DetalleVenta {
  final int id;
  final int ventaId;
  final int productoId;
  final String? productoNombre;
  final String? productoImagen;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleVenta({
    required this.id,
    required this.ventaId,
    required this.productoId,
    this.productoNombre,
    this.productoImagen,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      id: json['id'] ?? 0,
      ventaId: json['venta'] ?? 0,
      productoId: json['producto'] ?? 0,
      productoNombre: json['producto_nombre'],
      productoImagen: json['producto_imagen'],
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: double.parse(json['precio_unitario']?.toString() ?? '0'),
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venta': ventaId,
      'producto': productoId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
