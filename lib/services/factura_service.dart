import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/factura.dart';
import '../utils/config.dart';
import 'login_services.dart';

class FacturaService {
  final LoginService _loginService = LoginService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _loginService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Factura>> fetchFacturas() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/facturas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Factura.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar facturas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Factura> getFactura(int facturaId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/facturas/$facturaId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Factura.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar factura');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<ConceptoPago>> fetchConceptos() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/conceptos-pago/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ConceptoPago.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar conceptos de pago');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<DetalleFactura>> fetchDetalles(int facturaId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/detalles-factura/?factura=$facturaId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DetalleFactura.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar detalles de factura');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Factura> crearFactura(Factura factura) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/facturas/'),
        headers: headers,
        body: jsonEncode(factura.toJson()),
      );

      if (response.statusCode == 201) {
        return Factura.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al crear factura');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<DetalleFactura> agregarDetalle({
    required int facturaId,
    required int conceptoId,
    int? reservaId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final payload = {
        'factura': facturaId,
        'concepto': conceptoId,
        'reserva': null, // Siempre null según tu requerimiento
      };

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/detalles-factura/'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return DetalleFactura.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al agregar detalle');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarDetalle(int detalleId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/detalles-factura/$detalleId/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception(
            'Token expirado. Por favor, inicia sesión nuevamente.',
          );
        } else {
          throw Exception('Error al eliminar detalle');
        }
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
