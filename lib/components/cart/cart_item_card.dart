import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../utils/app_colors.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onUpdateQuantity;
  final Function() onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imagenUrl ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  Text(
                    'Bs. ${item.product.precioVenta.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Controles de cantidad
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: () => onUpdateQuantity(item.quantity - 1),
                      ),
                      
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: () => onUpdateQuantity(item.quantity + 1),
                      ),
                      
                      Spacer(),
                      
                      // Botón eliminar
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        color: AppColors.error,
                        onPressed: onRemove,
                        tooltip: 'Eliminar del carrito',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }
}