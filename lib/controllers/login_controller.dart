import 'package:condominium_app/services/login_services.dart';
import 'package:condominium_app/services/push_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  /// Realiza el login y retorna true si es exitoso, false si no.
  /// Lanza una excepción si hay error de conexión.
  Future<bool> login(String user, String password) async {
    final loginService = LoginService();
    try {
      final result = await loginService.login(user, password);
      
      // Si result no es null, significa que el login fue exitoso
      if (result != null) {
        print('\n🔐 Login exitoso, registrando token FCM...');
        
        // IMPORTANTE: Esperar un poco para asegurar que SharedPreferences guardó el token
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Registrar token FCM en el backend
        final prefs = await SharedPreferences.getInstance();
        final jwtToken = prefs.getString('jwt_token');
        
        print('🔍 JWT Token encontrado: ${jwtToken != null ? "✅ Sí" : "❌ No"}');
        
        if (jwtToken != null && jwtToken.isNotEmpty) {
          print('� Llamando a registrarTokenEnBackend...');
          final registrado = await PushNotificationService.registrarTokenEnBackend(jwtToken);
          
          if (registrado) {
            print('✅✅✅ TOKEN FCM REGISTRADO EN BACKEND ✅✅✅');
          } else {
            print('⚠️ No se pudo registrar el token FCM');
          }
        } else {
          print('❌ No se encontró JWT token en SharedPreferences');
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
