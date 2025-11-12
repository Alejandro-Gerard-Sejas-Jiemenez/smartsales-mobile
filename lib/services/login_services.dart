import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../models/user.dart';

class LoginService {
  Future<Map<String, dynamic>?> login(String correo, String password) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}');
    print('📡 Intentando login a: $url');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': password}),
      );

      print('📡 Código de respuesta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Login exitoso');
        
        if (data.containsKey('access')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['access']);
          await prefs.setString('refresh_token', data['refresh'] ?? '');
          
          // Guardar info de usuario si viene en la respuesta
          if (data.containsKey('usuario')) {
            await prefs.setString('user_data', jsonEncode(data['usuario']));
          }
          
          return data;
        }
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        print("❌ Credenciales inválidas: ${data['detail']}");
        throw Exception(data['detail'] ?? 'Credenciales inválidas');
      } else if (response.statusCode == 423) {
        final data = json.decode(response.body);
        print("❌ Usuario bloqueado: ${data['detail']}");
        throw Exception(data['detail'] ?? 'Usuario bloqueado');
      } else {
        print("❌ Error al hacer login: ${response.statusCode}");
        print("Respuesta: ${response.body}");
        throw Exception('Error al hacer login: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error durante el login: $e");
      rethrow;
    }
    
    return null;
  }

  Future<User?> getPerfil() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.perfil}');
      final response = await http.get(
        url,
        headers: ApiHeaders.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        
        // Guardar en preferencias
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));
        
        return user;
      }
    } catch (e) {
      print('Error obteniendo perfil: $e');
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      final refreshToken = await getRefreshToken();
      
      if (token != null && refreshToken != null) {
        final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.logout}');
        await http.post(
          url,
          headers: ApiHeaders.getHeaders(token: token),
          body: jsonEncode({'refresh': refreshToken}),
        );
      }
    } catch (e) {
      print('Error al hacer logout: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
    }
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Error obteniendo usuario: $e');
    }
    return null;
  }
}
