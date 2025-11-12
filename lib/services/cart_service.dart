import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/local_storage.dart';

class CartService {
  Future<Map<String, dynamic>> _getCurrentCart() async {
    final token = await LocalStorage.getToken();
    final userData = await LocalStorage.getUser();
    
    if (userData == null) {
      throw Exception('Usuario no autenticado');
    }

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    try {
      print('Obteniendo carrito - URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}');
      print('Headers: ${ApiHeaders.getHeaders(token: token)}');
      
      // Primero intentamos obtener el carrito existente
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}'),
        headers: ApiHeaders.getHeaders(token: token),
      );
      
      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      // Verificar si la respuesta es HTML (error)
      if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html>')) {
        throw Exception('El servidor devolvió HTML en lugar de JSON. Posible error de conexión o URL incorrecta.');
      }

      if (response.statusCode == 200) {
        try {
          final List<dynamic> carritos = json.decode(response.body);
          if (carritos.isNotEmpty) {
            // Cast explícito a Map<String, dynamic>
            final firstCarrito = carritos.first;
            if (firstCarrito is Map<String, dynamic>) {
              return firstCarrito;
            } else {
              throw Exception('El carrito no es un Map válido. Tipo: ${firstCarrito.runtimeType}');
            }
          }
        } catch (e) {
          print('Error decodificando JSON: $e');
          print('Respuesta completa: ${response.body}');
          throw Exception('Error al procesar la respuesta del servidor');
        }
      }
      
      // Si no hay carrito, creamos uno nuevo
      final createResponse = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}'),
        headers: ApiHeaders.getHeaders(token: token),
        body: json.encode({}), // El backend maneja la asociación automáticamente
      );

      if (createResponse.statusCode != 201) {
        final errorMsg = json.decode(createResponse.body)['detail'] ?? 'Error desconocido';
        throw Exception('Error al crear carrito: $errorMsg');
      }
      
      return json.decode(createResponse.body);
    } catch (e) {
      throw Exception('Error al gestionar el carrito: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final carrito = await _getCurrentCart();
      final detalles = carrito['detalles'] ?? [];
      
      // Convertir cada elemento explícitamente
      return detalles.map<Map<String, dynamic>>((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else {
          throw Exception('Detalle del carrito no es un Map válido. Tipo: ${item.runtimeType}, Valor: $item');
        }
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener el carrito: $e');
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      final token = await LocalStorage.getToken();
      
      print('Agregando al carrito - URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.detallesCarrito}');
      print('Headers: ${ApiHeaders.getHeaders(token: token)}');
      print('Body: ${json.encode({
        'producto': productId,
        'cantidad': quantity,
      })}');
      
      // Agregamos el producto al carrito - el backend se encarga de asociarlo al carrito correcto
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.detallesCarrito}'),
        headers: ApiHeaders.getHeaders(token: token),
        body: json.encode({
          'producto': productId,
          'cantidad': quantity,
        }),
      );
      
      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode != 201) {
        final errorMsg = json.decode(response.body)['detail'] ?? 'Error desconocido';
        throw Exception('Error al agregar al carrito: $errorMsg');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> updateCartItem(int itemId, int quantity) async {
    try {
      final token = await LocalStorage.getToken();
      
      // Solo enviar al backend, no esperar respuesta ni recargar
      http.patch(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.detallesCarrito}$itemId/'),
        headers: ApiHeaders.getHeaders(token: token),
        body: json.encode({
          'cantidad': quantity,
        }),
      ).then((response) {
        if (response.statusCode != 200) {
          print('Error al actualizar carrito: ${response.body}');
        }
      }).catchError((e) {
        print('Error de conexión al actualizar: $e');
      });
      
      // No hacemos throw ni esperamos, solo enviamos
    } catch (e) {
      print('Error al preparar actualización: $e');
    }
  }
  
  Future<void> syncCart() async {
    // Método para sincronizar todo el carrito cuando sea necesario
    try {
      final token = await LocalStorage.getToken();
      await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}'),
        headers: ApiHeaders.getHeaders(token: token),
      );
    } catch (e) {
      print('Error al sincronizar carrito: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final token = await LocalStorage.getToken();
      
      print('Vaciando carrito - URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}vaciar_carrito/');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.carritos}vaciar_carrito/'),
        headers: ApiHeaders.getHeaders(token: token),
      );
      
      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode != 200) {
        final errorMsg = json.decode(response.body)['detail'] ?? 'Error desconocido';
        throw Exception('Error al vaciar el carrito: $errorMsg');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> removeFromCart(int itemId) async {
    try {
      final token = await LocalStorage.getToken();
      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.detallesCarrito}$itemId/'),
        headers: ApiHeaders.getHeaders(token: token),
      );

      if (response.statusCode != 204) {
        final errorMsg = json.decode(response.body)['detail'] ?? 'Error desconocido';
        throw Exception('Error al eliminar del carrito: $errorMsg');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<double> getCartTotal() async {
    try {
      final carrito = await _getCurrentCart();
      return double.parse(carrito['total']?.toString() ?? '0');
    } catch (e) {
      throw Exception('Error al obtener el total del carrito: $e');
    }
  }
}