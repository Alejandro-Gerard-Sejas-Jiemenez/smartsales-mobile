import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pago.dart';
import '../utils/config.dart';
import 'login_services.dart';

class PagoService {
  final LoginService _loginService = LoginService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _loginService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<PaymentIntentResponse> crearPaymentIntent(int facturaId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/pagos/crear_payment_intent/'),
        headers: headers,
        body: jsonEncode({'factura_id': facturaId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PaymentIntentResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al crear payment intent');
      }
    } catch (e) {
      if (e.toString().contains('Token expirado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> confirmarPagoFacturaBackend(int facturaId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/pagos/confirmar_pago/'),
        headers: headers,
        body: jsonEncode({'factura_id': facturaId}),
      );

      if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al confirmar pago');
      }
    } catch (e) {
      if (e.toString().contains('Token expirado')) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Pago>> fetchPagos() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/pagos/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Pago.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar pagos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
