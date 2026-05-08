import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elapas_app/core/network/dio_client.dart';

final cutRepositoryProvider = Provider<CutRepository>((ref) {
  return CutRepository(ref.watch(dioProvider));
});

class CutRepository {
  final Dio _dio;
  CutRepository(this._dio);

  Future<List<dynamic>> getAssignedCuts() async {
    try {
      final response = await _dio.get('/cuts/assigned');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cargar cortes');
    }
  }

  Future<void> executeCut({
    required String cutId,
    required double lat,
    required double lng,
    required String photoUrl,
  }) async {
    try {
      // Enviamos el body con la evidencia requerida por el backend
      await _dio.patch('/cuts/$cutId/execute', data: {
        'gpsLat': lat,
        'gpsLng': lng,
        'photoUrl': photoUrl,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al ejecutar corte');
    }
  }
}
