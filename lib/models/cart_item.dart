import 'product.dart';

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
    return CartItem(
      id: json['id'] as int,
      product: Product.fromJson(json['producto_info'] as Map<String, dynamic>),
      quantity: json['cantidad'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'product': product.toJson(),
      'quantity': quantity,
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