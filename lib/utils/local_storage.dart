import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _cartKey = 'cart_items';

  // Métodos para el token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Métodos para los datos del usuario
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userString = json.encode(userData);
    await prefs.setString(_userKey, userString);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  // Métodos para el carrito
  static Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = json.encode(items);
    await prefs.setString(_cartKey, cartString);
  }

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    if (cartString != null) {
      final List<dynamic> decodedList = json.decode(cartString);
      return decodedList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Limpiar datos
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}