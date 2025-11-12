import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venta.dart';
import '../utils/api_constants.dart';
import '../utils/local_storage.dart';

class VentaService {
  Future<List<Venta>> getMisCompras() async {
    try {
      final token = await LocalStorage.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/api/ventas/mis_compras/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Respuesta mis compras: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('📦 Datos recibidos: ${data.length} compras');
        if (data.isNotEmpty) {
          print('📋 Primera compra: ${data[0]}');
        }
        return data.map((json) => Venta.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar compras: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getMisCompras: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Venta> getDetalleVenta(int ventaId) async {
    try {
      final token = await LocalStorage.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/api/ventas/$ventaId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Respuesta detalle venta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Venta.fromJson(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar detalle: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getDetalleVenta: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
