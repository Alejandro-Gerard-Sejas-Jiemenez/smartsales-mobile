import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../utils/local_storage.dart';

class CategoryService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<Category>> getCategories() async {
    try {
      final token = await LocalStorage.getToken();
      print('🔑 Token en CategoryService: ${token?.substring(0, 20)}...');
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categorias/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Respuesta categorías: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getCategories: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
