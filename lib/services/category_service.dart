import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../utils/local_storage.dart';
import '../utils/api_constants.dart';

class CategoryService {
  // Usar el baseUrl centralizado; en `api_constants.dart` está configurado al EC2.
  final String baseUrl = ApiEndpoints.baseUrl + '/api';

  Future<List<Category>> getCategories() async {
    try {
      final token = await LocalStorage.getToken();
      print('🔑 Token en CategoryService: ${token?.substring(0, 20)}...');
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        // Construir URI de forma segura
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.categorias}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Respuesta categorías: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        // Asegurarnos de que sea una lista antes de mapear
        final List<dynamic> data = (decoded is List) ? decoded : (decoded['results'] ?? []);
        print('CategoryService: decoded type=${decoded.runtimeType}, data type=${data.runtimeType}, length=${data.length}');
        final List<Category> cats = data.map<Category>((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
        print('CategoryService: mapped cats runtimeType=${cats.runtimeType}, length=${cats.length}');
        return cats;
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
