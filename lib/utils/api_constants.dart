class ApiEndpoints {
  // 10.0.2.2 es la dirección especial para acceder al localhost desde el emulador de Android
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  // Auth endpoints
  static const String login = '/api/acceso_seguridad/token/';
  static const String register = '/api/acceso_seguridad/registro/';
  static const String logout = '/api/acceso_seguridad/logout/';
  static const String perfil = '/api/acceso_seguridad/perfil/';
  static const String tokenRefresh = '/api/acceso_seguridad/token/refresh/';
  static const String solicitarRecuperacion = '/api/acceso_seguridad/solicitar-recuperacion/';
  static const String confirmarRecuperacion = '/api/acceso_seguridad/confirmar-recuperacion/';
  
  // Usuarios y clientes
  static const String usuarios = '/api/acceso_seguridad/usuarios/';
  static const String clientes = '/api/clientes/';
  static const String bitacora = '/api/acceso_seguridad/bitacora/';
  static const String avisos = '/api/acceso_seguridad/avisos/';
  
  // Catálogo endpoints
  static const String categorias = '/api/categorias/';
  static const String productos = '/api/productos/';
  static const String inventarios = '/api/inventarios/';
  static const String inventarioProductos = '/api/inventario-productos/';
  
  // Carrito y ventas endpoints
  static const String carritos = '/api/carritos/';
  static const String detallesCarrito = '/api/detalles-carrito/';
  static const String ventas = '/api/ventas/';
  static const String detallesVenta = '/api/detalles-venta/';
  static const String pagos = '/api/pagos/';
  
  // Predicciones endpoints
  static const String prediccionesVentas = '/api/predicciones-ventas/';
}

class ApiHeaders {
  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}