class TopProduct {
  final int productoId;
  final String nombre;
  final String? imagenUrl;
  final int cantidadVendida;
  final double totalVenta;

  TopProduct({
    required this.productoId,
    required this.nombre,
    this.imagenUrl,
    required this.cantidadVendida,
    required this.totalVenta,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productoId: json['producto_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      imagenUrl: json['imagen_url'],
      cantidadVendida: (json['cantidad_vendida'] ?? 0) is int
          ? json['cantidad_vendida']
          : int.parse((json['cantidad_vendida'] ?? 0).toString()),
      totalVenta: (json['total_venta'] ?? 0.0) is double
          ? json['total_venta']
          : double.parse((json['total_venta'] ?? 0).toString()),
    );
  }
}
