import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../components/common/custom_app_bar.dart';
import '../../components/cart/cart_item_card.dart';
import '../../models/cart_item.dart';
import '../../models/venta.dart';
import '../../services/cart_service.dart';
import '../../services/payment_service.dart';
import '../../services/venta_service.dart';
import '../../utils/app_colors.dart';
import '../purchase/receipt_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  final _paymentService = PaymentService();
  final _ventaService = VentaService();
  bool _isLoading = true;
  String? _error;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final itemsData = await _cartService.getCartItems();
      final items = itemsData.map((item) => CartItem.fromJson(item)).toList();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(int itemId, int quantity) async {
    if (quantity <= 0) {
      // Si la cantidad es 0, eliminar el producto
      _removeItem(itemId);
      return;
    }
    
    // Actualizar localmente primero (optimista)
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      }
    });
    
    // Enviar al backend en segundo plano (sin esperar)
    _cartService.updateCartItem(itemId, quantity);
  }

  Future<void> _removeItem(int itemId) async {
    // Eliminar localmente primero (optimista)
    setState(() {
      _cartItems.removeWhere((item) => item.id == itemId);
    });
    
    // Enviar eliminación al backend en segundo plano
    try {
      await _cartService.removeFromCart(itemId);
    } catch (e) {
      // Si falla, recargar para sincronizar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar. Recargando...'),
          backgroundColor: AppColors.error,
        ),
      );
      _loadCart();
    }
  }

  Future<void> _clearCart() async {
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vaciar carrito'),
          content: Text('¿Estás seguro de que deseas eliminar todos los productos del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: Text('Vaciar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);
      
      await _cartService.clearCart();
      
      setState(() {
        _cartItems.clear();
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Carrito vaciado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al vaciar el carrito: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _processCheckout() async {
    try {
      setState(() => _isLoading = true);
      
      // PASO 1: Sincronizar el carrito con el backend
      await _cartService.syncCart();
      
      // PASO 2: Recargar para asegurarnos de tener los datos correctos
      await _loadCart();
      
      if (_cartItems.isEmpty) {
        throw Exception('El carrito está vacío');
      }
      
      // PASO 3: Crear la venta desde el carrito
      final ventaData = await _paymentService.createSaleFromCart();
      final ventaId = ventaData['id'] as int;
      
      print('Venta creada con ID: $ventaId');
      
      // PASO 4: Crear el PaymentIntent de Stripe
      final paymentData = await _paymentService.createPaymentIntent(ventaId);
      final clientSecret = paymentData['client_secret'] as String;
      
      print('PaymentIntent creado: ${paymentData['payment_intent_id']}');
      
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      // PASO 5: Mostrar la pasarela de pago de Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SmartSales365',
          style: ThemeMode.light,
        ),
      );
      
      // PASO 6: Presentar la hoja de pago
      await Stripe.instance.presentPaymentSheet();
      
      // PASO 7: Si llegamos aquí, el pago fue exitoso
      // Confirmar el pago en el backend
      await _paymentService.confirmPayment(paymentData['payment_intent_id']);
      
      // PASO 8: Obtener el detalle completo de la venta para mostrar el recibo
      final ventaCompleta = await _ventaService.getDetalleVenta(ventaId);
      
      // PASO 9: Limpiar el carrito localmente
      setState(() {
        _cartItems.clear();
      });
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pago realizado exitosamente!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navegar a la pantalla de comprobante
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(venta: ventaCompleta),
        ),
      );
      
    } on StripeException catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      String errorMessage = 'Error en el pago';
      if (e.error.code == FailureCode.Canceled) {
        errorMessage = 'Pago cancelado';
      } else if (e.error.localizedMessage != null) {
        errorMessage = e.error.localizedMessage!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar la compra: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  double get _total => _cartItems.fold(
        0,
        (sum, item) => sum + item.total,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Carrito de Compras',
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearCart,
              tooltip: 'Vaciar carrito',
            ),
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _cartService.syncCart();
                await _loadCart();
              },
              tooltip: 'Sincronizar carrito',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error al cargar el carrito',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _loadCart,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay productos en el carrito',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return CartItemCard(
                                item: item,
                                onUpdateQuantity: (quantity) => 
                                    _updateQuantity(item.id, quantity),
                                onRemove: () => _removeItem(item.id),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Bs. ${_total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _processCheckout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Proceder al Pago',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}