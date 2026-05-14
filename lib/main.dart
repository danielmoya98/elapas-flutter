import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 NUEVO
import 'firebase_options.dart'; // 🔥 NUEVO: Archivo generado por FlutterFire
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/push_notification_service.dart'; // 🔥 NUEVO: El servicio que creamos

void main() async {
  // 🔥 REQUERIDO: Asegura que el motor de Flutter esté listo antes de usar código nativo (Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INICIALIZAR FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 INICIALIZAR NOTIFICACIONES
  await PushNotificationService.initializeApp();

  runApp(
    // ProviderScope es obligatorio para que Riverpod funcione en toda la app
    const ProviderScope(
      child: ElapasApp(),
    ),
  );
}

class ElapasApp extends ConsumerWidget {
  const ElapasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el router que configuramos
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ELAPAS Operaciones',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // themeMode: ThemeMode.system, // Descomentar cuando implementemos el Dark Mode
      routerConfig: router,
    );
  }
}
