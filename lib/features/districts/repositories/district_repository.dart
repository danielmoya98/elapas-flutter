import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

// Proveedor del repositorio
final districtRepositoryProvider = Provider<DistrictRepository>((ref) {
  return DistrictRepository(ref.watch(dioProvider));
});

// 🔥 Proveedor asíncrono para manejar estado de carga y error en la UI
final districtsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(districtRepositoryProvider);
  return repository.getDistricts();
});

class DistrictRepository {
  final Dio _dio;

  DistrictRepository(this._dio);

  Future<List<dynamic>> getDistricts() async {
    try {
      final response = await _dio.get('/districts');
      // Dependiendo de tu backend, podría ser response.data o response.data['data']
      // Asumimos que Prisma devuelve el array directo
      return response.data;
    } catch (e) {
      throw Exception('Error al cargar los distritos');
    }
  }
}
