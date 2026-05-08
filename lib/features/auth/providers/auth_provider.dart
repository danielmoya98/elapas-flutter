import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  // --- AQUÍ ESTÁ LA FUNCIÓN DENTRO DE LA CLASE ---
  Future<void> login(
      AuthRepository authRepo, String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.checking);

      final data = await authRepo.login(email, password);

      final token = data['accessToken'];
      final user = data['user'];
      final role = user['role'];

      await loginSuccess(token, role, user['email']);
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
