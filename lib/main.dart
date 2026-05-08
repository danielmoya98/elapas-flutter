import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
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
