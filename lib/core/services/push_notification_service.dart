import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// 🔥 Manejador para mensajes en segundo plano (DEBE ser una función de nivel superior, fuera de cualquier clase)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensaje recibido en segundo plano: ${message.messageId}");
}

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initializeApp() async {
    // 1. Pedir permisos (Crítico para iOS y Android 13+)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Configurar el manejador para cuando la app está en Background o Cerrada
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Escuchar notificaciones cuando la app está ABIERTA (Primer Plano)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');

      // Aquí puedes usar un paquete como 'flutter_local_notifications' para mostrar
      // una tarjeta estilo sistema, o simplemente mostrar un Snackbar si tienes acceso al context global.
      // Ejemplo básico de impresión:
      if (message.notification != null) {
        print('Título: ${message.notification!.title}');
        print('Cuerpo: ${message.notification!.body}');
      }
    });

    // 4. Escuchar cuando el usuario TOCA la notificación para abrir la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('El usuario tocó la notificación: ${message.data}');
      // Aquí puedes redirigir a una pantalla específica dependiendo del message.data['type']
      // Ejemplo: si type == 'CUT_ASSIGNED', navegas a la pantalla de órdenes.
    });
  }
}
