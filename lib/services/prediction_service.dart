import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/local_storage.dart';

class PredictionService {

  /// Obtiene la lista de predicciones desde el backend.
  /// Devuelve una `List<dynamic>` con los objetos de predicción.
  Future<List<dynamic>> getPredictions({int? categoriaId}) async {
    try {
      final token = await LocalStorage.getToken();

      // Construir URI con posible query param `categoria`
      String url = '${ApiEndpoints.baseUrl}${ApiEndpoints.prediccionesVentas}';
      if (categoriaId != null) {
        // Asegurar que termina con / para mantener compatibilidad
        url = '$url?categoria=$categoriaId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token != null ? 'Bearer $token' : '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        // Si el backend envía un objeto, intentar obtener el campo 'results'
        if (decoded is Map && decoded.containsKey('results')) {
          return decoded['results'] as List<dynamic>;
        }
        // De otro modo, envolver en lista
        return [decoded];
      } else if (response.statusCode == 401) {
        throw Exception('No autenticado. Por favor inicie sesión.');
      } else {
        throw Exception('Error al obtener predicciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Mock data for testing / fallback
  Future<Map<String, dynamic>> getMockPredictions() async {
    await Future.delayed(Duration(seconds: 1)); // Simular delay de red
    return {
      'expected_sales': 15000,
      'sales_growth': 12.5,
      'top_products_count': 15,
      'products_growth': 8.2,
      'trend_data': [
        {'x': 0, 'y': 1000},
        {'x': 1, 'y': 1200},
        {'x': 2, 'y': 1100},
        {'x': 3, 'y': 1400},
        {'x': 4, 'y': 1300},
        {'x': 5, 'y': 1600},
        {'x': 6, 'y': 1500},
      ],
    };
  }
}