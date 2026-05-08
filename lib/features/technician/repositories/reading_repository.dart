import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elapas_app/core/network/dio_client.dart';

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  return ReadingRepository(ref.watch(dioProvider));
});

class ReadingRepository {
  final Dio _dio;
  ReadingRepository(this._dio);

  // 1. Buscar Medidor por Código
  Future<Map<String, dynamic>> getMeterByCode(String code) async {
    try {
      final response = await _dio.get('/readings/meter/$code');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Medidor no encontrado');
    }
  }

  // 2. Enviar la Lectura
  Future<void> submitReading({
    required String meterId,
    required double currentReading,
    required double lat,
    required double lng,
    required String photoUrl, // Ahora es requerido y dinámico
  }) async {
    try {
      await _dio.post('/readings', data: {
        'meterId': meterId,
        'currentReading': currentReading,
        'gpsLat': lat,
        'gpsLng': lng,
        'photoUrl': photoUrl,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al enviar lectura');
    }
  }
}
