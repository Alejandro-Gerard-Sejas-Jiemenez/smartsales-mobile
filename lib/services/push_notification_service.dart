import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ⚠️ IMPORTANTE: Cambia esta IP por la de tu PC
  // Windows: abre CMD → escribe "ipconfig" → busca IPv4
  // Si usas emulador: usa 10.0.2.2
  // Si usas celular físico: usa tu IP local (ej: 192.168.1.100)
  static const String backendUrl = 'http://10.0.2.2:8000'; // ← CAMBIA AQUÍ

  /// Inicializar el servicio de notificaciones push
  static Future<void> initializeApp() async {
    print('🔔 Inicializando notificaciones push...');

    // 1. Solicitar permisos
    await _requestPermission();

    // 2. Obtener token FCM
    try {
      token = await FirebaseMessaging.instance.getToken();
      if (token != null && token!.isNotEmpty) {
        print('✅ Token FCM obtenido exitosamente');
        print('📱 Token (primeros 30 chars): ${token!.substring(0, token!.length > 30 ? 30 : token!.length)}...');
      } else {
        print('❌ ERROR: Token FCM es null o vacío');
        print('⚠️ Verifica que google-services.json esté configurado correctamente');
      }
    } catch (e) {
      print('❌ ERROR al obtener token FCM: $e');
    }

    // 3. Configurar notificaciones locales
    await _initializeLocalNotifications();

    // 4. Escuchar notificaciones en foreground (app abierta)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Escuchar cuando usuario toca notificación (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 6. Verificar si app fue abierta por notificación (estaba cerrada)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('🚀 App abierta desde notificación: ${message.notification?.title}');
        _handleMessageOpenedApp(message);
      }
    });

    // 7. Escuchar renovación de token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 Token FCM renovado: $newToken');
      token = newToken;
    });
  }

  /// Solicitar permisos de notificaciones
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permisos de notificación concedidos');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Permisos provisionales concedidos');
    } else {
      print('❌ Permisos de notificación denegados');
    }
  }

  /// Configurar plugin de notificaciones locales
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🔔 Usuario tocó notificación local: ${response.payload}');
      },
    );

    // Crear canal de notificaciones de alta importancia
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificaciones Importantes',
      description: 'Canal para notificaciones importantes de SmartSales365',
      importance: Importance.high,
    );

    // ✅ LÍNEA CORREGIDA - Agregado el símbolo <
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Manejar notificación cuando app está abierta (foreground)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📩 Notificación recibida en foreground:');
    print('   Título: ${message.notification?.title}');
    print('   Mensaje: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Mostrar notificación local
    await _showLocalNotification(message);
  }

  /// Mostrar notificación local
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'Notificaciones Importantes',
      channelDescription: 'Canal para notificaciones importantes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title ?? 'SmartSales365',
      message.notification?.body ?? '',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Manejar cuando usuario toca la notificación
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('👆 Usuario tocó notificación:');
    print('   Título: ${message.notification?.title}');
    print('   Data: ${message.data}');

    // TODO: Navegar a pantalla específica según el tipo de notificación
    // Ejemplo:
    // if (message.data['tipo'] == 'oferta') {
    //   navigatorKey.currentState?.pushNamed('/ofertas');
    // }
  }

  /// Registrar token en el backend Django
  static Future<bool> registrarTokenEnBackend(String jwtToken) async {
    print('\n═══════════════════════════════════════════════');
    print('🔄 REGISTRANDO TOKEN FCM EN BACKEND');
    print('═══════════════════════════════════════════════');
    
    if (token == null || token!.isEmpty) {
      print('❌ ERROR: No hay token FCM disponible');
      print('   Solución: Reinicia la app y verifica permisos');
      return false;
    }

    print('✅ Token FCM disponible: ${token!.substring(0, 30)}...');
    print('🔐 JWT Token disponible: ${jwtToken.substring(0, 20)}...');
    print('🌐 URL: $backendUrl/api/acceso_seguridad/registrar-token/');
    print('📱 Plataforma: android');

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/acceso_seguridad/registrar-token/'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'plataforma': 'android',
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió en 10 segundos');
        },
      );

      print('📡 Respuesta del servidor: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅✅✅ TOKEN REGISTRADO EXITOSAMENTE ✅✅✅');
        print('═══════════════════════════════════════════════\n');
        return true;
      } else {
        print('❌ Error HTTP ${response.statusCode}');
        print('   Respuesta: ${response.body}');
        print('═══════════════════════════════════════════════\n');
        return false;
      }
    } catch (e) {
      print('❌ ERROR DE RED: $e');
      print('');
      print('⚠️ POSIBLES CAUSAS:');
      print('   1. Backend no está corriendo (ejecuta: python manage.py runserver)');
      print('   2. IP incorrecta en backendUrl');
      print('      - Emulador: usa 10.0.2.2');
      print('      - Celular físico: usa tu IP local (ipconfig en Windows)');
      print('   3. Firewall bloqueando la conexión');
      print('═══════════════════════════════════════════════\n');
      return false;
    }
  }

  /// Obtener token actual
  static String? getToken() {
    return token;
  }
}