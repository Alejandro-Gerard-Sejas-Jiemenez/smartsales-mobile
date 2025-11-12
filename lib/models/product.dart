class Product {
  final int id;
  final String codigoProducto;
  final String nombre;
  final String? descripcion;
  final double precioVenta;
  final double precioCompra;
  final int stockActual;
  final String? imagenUrl;
  final String estado; // 'Disponible', 'Agotado', 'Descontinuado'
  final int anoGarantia;
  final String? marca;
  final int categoria;
  final String? fechaCreacion;

  Product({
    required this.id,
    required this.codigoProducto,
    required this.nombre,
    this.descripcion,
    required this.precioVenta,
    required this.precioCompra,
    required this.stockActual,
    this.imagenUrl,
    required this.estado,
    required this.anoGarantia,
    this.marca,
    required this.categoria,
    this.fechaCreacion,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      codigoProducto: json['codigo_producto'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precioVenta: double.parse(json['precio_venta']?.toString() ?? '0'),
      precioCompra: double.parse(json['precio_compra']?.toString() ?? '0'),
      stockActual: json['stock_actual'] ?? 0,
      imagenUrl: json['imagen_url'],
      estado: json['estado'] ?? 'Disponible',
      anoGarantia: json['ano_garantia'] ?? 0,
      marca: json['marca'],
      categoria: json['categoria'] ?? 0,
      fechaCreacion: json['fecha_creacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_producto': codigoProducto,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_venta': precioVenta,
      'precio_compra': precioCompra,
      'stock_actual': stockActual,
      'imagen_url': imagenUrl,
      'estado': estado,
      'ano_garantia': anoGarantia,
      'marca': marca,
      'categoria': categoria,
      'fecha_creacion': fechaCreacion,
    };
  }

  bool get isAvailable => estado == 'Disponible' && stockActual > 0;
  bool get isOutOfStock => estado == 'Agotado' || stockActual == 0;
  bool get isDiscontinued => estado == 'Descontinuado';
}