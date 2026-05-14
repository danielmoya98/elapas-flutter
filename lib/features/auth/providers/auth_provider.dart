import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 🔥 IMPORTACIÓN DE FIREBASE AÑADIDA
import '../repositories/auth_repository.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

enum AppRole { none, tecnico, cliente }

class AuthState {
  final AuthStatus status;
  final AppRole role;
  final String? email;

  AuthState(
      {this.status = AuthStatus.checking,
      this.role = AppRole.none,
      this.email});

  AuthState copyWith({AuthStatus? status, AppRole? role, String? email}) {
    return AuthState(
      status: status ?? this.status,
      role: role ?? this.role,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt_token');
    final roleStr = await _storage.read(key: 'user_role');

    if (token == null || roleStr == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    final role = roleStr == 'TECNICO' ? AppRole.tecnico : AppRole.cliente;
    state = state.copyWith(status: AuthStatus.authenticated, role: role);
  }

  Future<void> loginSuccess(String token, String role, String email) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_role', value: role);
    await _storage.write(key: 'user_email', value: email);

    final appRole = role == 'TECNICO' ? AppRole.tecnico : AppRole.cliente;
    state = state.copyWith(
        status: AuthStatus.authenticated, role: appRole, email: email);
  }

  Future<void> login(
      AuthRepository authRepo, String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.checking);

      // 1. Hacemos el login en el backend
      final data = await authRepo.login(email, password);

      final token = data['accessToken'];
      final user = data['user'];
      final role = user['role'];

      // 2. Guardamos la sesión localmente
      await loginSuccess(token, role, user['email']);

      // 🔥 3. NUEVO: Obtenemos el token de notificaciones de este celular y lo mandamos al backend
      try {
        // Pedimos permisos al sistema operativo (Obligatorio en iOS 14+ y Android 13+)
        await FirebaseMessaging.instance.requestPermission();

        // Extraemos el token único de este dispositivo
        final fcmToken = await FirebaseMessaging.instance.getToken();

        // Si Firebase nos devolvió un token válido, lo sincronizamos con NestJS
        if (fcmToken != null) {
          await authRepo.updateFcmToken(fcmToken);
        }
      } catch (e) {
        // Envolvemos esto en un try-catch independiente para que si Firebase falla
        // por falta de internet o configuraciones, el usuario igual pueda entrar a la app.
        print('Advertencia - Omitiendo configuración de FCM: $e');
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  // Función para registrar al cliente
  Future<void> register(
      AuthRepository authRepo, Map<String, dynamic> customerData) async {
    try {
      state = state.copyWith(status: AuthStatus.checking);

      // Solo lo registramos, el login debe hacerlo el usuario después
      await authRepo.register(customerData);

      // Como el registro fue exitoso, lo dejamos desautenticado para que inicie sesión
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = state.copyWith(
        status: AuthStatus.unauthenticated, role: AppRole.none, email: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
