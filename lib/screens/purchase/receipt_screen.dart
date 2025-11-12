import 'package:flutter/material.dart';
import '../../models/venta.dart';
import '../../utils/app_colors.dart';

class ReceiptScreen extends StatelessWidget {
  final Venta venta;

  const ReceiptScreen({Key? key, required this.venta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Comprobante de Venta',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('🔙 Flecha presionada - navegando al home');
            // Navegar a /home reemplazando la ruta actual
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implementar compartir comprobante
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Función de compartir próximamente')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 60,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'SmartSales365',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'NOTA DE VENTA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Divider(thickness: 1),
                  SizedBox(height: 16),

                  // Información de la venta
                  _buildInfoRow('No. Comprobante:', '#${venta.id}'),
                  SizedBox(height: 8),
                  _buildInfoRow('Fecha:', _formatearFecha(venta.fechaVenta)),
                  SizedBox(height: 8),
                  _buildInfoRow('Estado:', _getEstadoTexto(venta.estado ?? 'pendiente'), 
                    color: _getEstadoColor(venta.estado ?? 'pendiente')),
                  if (venta.metodoPago != null) ...[
                    SizedBox(height: 8),
                    _buildInfoRow('Método de Pago:', _getMetodoPagoTexto(venta.metodoPago!)),
                  ],
                  SizedBox(height: 16),
                  Divider(thickness: 1),
                  SizedBox(height: 16),

                  // Detalles de productos
                  Text(
                    'Detalle de Productos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),

                  if (venta.detalles != null && venta.detalles!.isNotEmpty)
                    ...venta.detalles!.map((detalle) => _buildProductoItem(detalle))
                  else
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No hay detalles disponibles',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16),
                  Divider(thickness: 1),
                  SizedBox(height: 16),

                  // Totales
                  _buildTotalRow('Subtotal:', venta.totalVenta),
                  SizedBox(height: 8),
                  _buildTotalRow('Descuento:', venta.descuento ?? 0.0, isDiscount: true),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a Pagar:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Bs. ${venta.totalVenta.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (venta.notas != null && venta.notas!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Divider(thickness: 1),
                    SizedBox(height: 12),
                    Text(
                      'Notas:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      venta.notas!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  SizedBox(height: 24),
                  Center(
                    child: Text(
                      '¡Gracias por su compra!',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Botón para volver al home
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print('🏠 Botón presionado - navegando al home');
                          // Navegar a /home reemplazando la ruta actual
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        icon: Icon(Icons.home),
                        label: Text('Volver a Productos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProductoItem(DetalleVenta detalle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalle.productoNombre ?? 'Producto sin nombre',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${detalle.cantidad} x Bs. ${detalle.precioUnitario.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Subtotal
          Text(
            'Bs. ${detalle.subtotal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '${isDiscount && value > 0 ? '-' : ''}Bs. ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
        return AppColors.success;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
        return 'Completada';
      case 'pendiente':
        return 'Pendiente';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  String _getMetodoPagoTexto(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'stripe':
        return 'Tarjeta de Crédito/Débito';
      case 'efectivo':
        return 'Efectivo';
      case 'qr':
        return 'QR';
      default:
        return metodo;
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final DateTime dt = DateTime.parse(fecha);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }
}
