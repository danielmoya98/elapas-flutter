import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Credenciales inválidas');
      }
      throw Exception('Error de conexión con el servidor');
    }
  }

  // Método para registrar al cliente
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // NestJS suele devolver un array de errores en class-validator
        final message = e.response?.data['message'];
        if (message is List) {
          throw Exception(message.join(', '));
        }
        throw Exception(message ?? 'Error al registrar la cuenta');
      }
      throw Exception('Error de conexión con el servidor');
    }
  }

  // 🔥 NUEVO: Método para enviar el token FCM al backend
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.patch('/auth/fcm-token', data: {
        'fcmToken': fcmToken,
      });
      print('Token FCM sincronizado con el backend exitosamente.');
    } catch (e) {
      print('Error al actualizar FCM Token en el servidor: $e');
      // No lanzamos la excepción hacia arriba porque un fallo en el token
      // no debería impedir que el usuario inicie sesión en la app.
    }
  }
}
