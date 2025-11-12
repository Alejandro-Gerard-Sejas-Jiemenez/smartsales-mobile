import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/local_storage.dart';

class PredictionService {

  Future<Map<String, dynamic>> getPredictions() async {
    try {
      final token = await LocalStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.prediccionesVentas}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener predicciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Mock data for testing
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