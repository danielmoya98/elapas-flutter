import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

// Pantallas placeholder por ahora
import '../../features/auth/screens/login_screen.dart';
import '../../features/technician/layout/tech_main_screen.dart';
import '../../features/customer/layout/customer_main_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.checking)
        return null; // Mostramos un splash screen

      if (!isAuth && !isGoingToLogin) {
        return '/login';
      }

      if (isAuth && isGoingToLogin) {
        return authState.role == AppRole.tecnico ? '/tech' : '/customer';
      }

      return null; // Deja pasar
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/customer',
        // Cambiamos CustomerHomeScreen por CustomerMainScreen
        builder: (context, state) => const CustomerMainScreen(),
      ),
      GoRoute(
        path: '/tech',
        builder: (context, state) =>
            const TechMainScreen(), // <--- Actualiza aquí
      ),
    ],
  );
});
