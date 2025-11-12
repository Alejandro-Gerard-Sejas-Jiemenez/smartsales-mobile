import 'product.dart';

class Carrito {
  final int id;
  final int clienteId;
  final String fechaCreacion;
  final double total;
  final List<DetalleCarrito>? detalles;

  Carrito({
    required this.id,
    required this.clienteId,
    required this.fechaCreacion,
    required this.total,
    this.detalles,
  });

  factory Carrito.fromJson(Map<String, dynamic> json) {
    return Carrito(
      id: json['id'] ?? 0,
      clienteId: json['cliente'] ?? 0,
      fechaCreacion: json['fecha_creacion'] ?? '',
      total: double.parse(json['total']?.toString() ?? '0'),
      detalles: json['detalles'] != null
          ? (json['detalles'] as List)
              .map((d) => DetalleCarrito.fromJson(d))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': clienteId,
      'fecha_creacion': fechaCreacion,
      'total': total,
      'detalles': detalles?.map((d) => d.toJson()).toList(),
    };
  }
}

class DetalleCarrito {
  final int id;
  final int carritoId;
  final Product? product;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleCarrito({
    required this.id,
    required this.carritoId,
    this.product,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleCarrito.fromJson(Map<String, dynamic> json) {
    return DetalleCarrito(
      id: json['id'] ?? 0,
      carritoId: json['carrito'] ?? 0,
      product: json['producto'] is Map
          ? Product.fromJson(json['producto'])
          : null,
      productoId: json['producto'] is int
          ? json['producto']
          : json['producto']?['id'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: double.parse(json['precio_unitario']?.toString() ?? '0'),
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carrito': carritoId,
      'producto': productoId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }

  DetalleCarrito copyWith({
    int? id,
    int? carritoId,
    Product? product,
    int? productoId,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
  }) {
    return DetalleCarrito(
      id: id ?? this.id,
      carritoId: carritoId ?? this.carritoId,
      product: product ?? this.product,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

// Mantener CartItem para compatibilidad
class CartItem {
  final int id;
  final Product product;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Obtener producto_info sin cast para evitar errores
    var productoInfoRaw = json['producto_info'];
    
    // Verificar si es un Map válido
    if (productoInfoRaw == null || productoInfoRaw is! Map<String, dynamic>) {
      throw Exception('producto_info es null o no es un Map. Tipo recibido: ${productoInfoRaw.runtimeType}. JSON completo: $json');
    }
    
    return CartItem(
      id: json['id'] as int,
      product: Product.fromJson(productoInfoRaw),
      quantity: json['cantidad'] ?? json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto': product.id,
      'product': product.toJson(),
      'cantidad': quantity,
    };
  }

  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => product.precioVenta * quantity;
}
