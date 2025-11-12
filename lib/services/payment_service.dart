import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/local_storage.dart';

class PaymentService {
  /// Crear una venta desde el carrito actual
  Future<Map<String, dynamic>> createSaleFromCart() async {
    try {
      final token = await LocalStorage.getToken();
      
      print('Creando venta desde carrito - URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}crear_venta_desde_carrito/');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}crear_venta_desde_carrito/'),
        headers: ApiHeaders.getHeaders(token: token),
      );
      
      print('Respuesta crear venta: ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorMsg = json.decode(response.body)['detail'] ?? 'Error desconocido';
        throw Exception('Error al crear venta: $errorMsg');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear venta: $e');
    }
  }

  /// Crear un PaymentIntent de Stripe
  Future<Map<String, dynamic>> createPaymentIntent(int ventaId) async {
    try {
      final token = await LocalStorage.getToken();
      
      print('Creando PaymentIntent - URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.pagos}crear_payment_intent/');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.pagos}crear_payment_intent/'),
        headers: ApiHeaders.getHeaders(token: token),
        body: json.encode({'venta_id': ventaId}),
      );
      
      print('Respuesta PaymentIntent: ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorMsg = json.decode(response.body)['error'] ?? 'Error desconocido';
        throw Exception('Error al crear PaymentIntent: $errorMsg');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear PaymentIntent: $e');
    }
  }

  /// Confirmar el pago después de que Stripe lo procese
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentId) async {
    try {
      final token = await LocalStorage.getToken();
      
      print('Confirmando pago - URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.pagos}confirmar_pago/');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.pagos}confirmar_pago/'),
        headers: ApiHeaders.getHeaders(token: token),
        body: json.encode({'payment_intent_id': paymentIntentId}),
      );
      
      print('Respuesta confirmar pago: ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorMsg = json.decode(response.body)['error'] ?? 'Error desconocido';
        throw Exception('Error al confirmar pago: $errorMsg');
      }
    } catch (e) {
      throw Exception('Error de conexión al confirmar pago: $e');
    }
  }
}
