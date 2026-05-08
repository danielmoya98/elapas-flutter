import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elapas_app/core/network/dio_client.dart';

final customerRepositoryProvider =
    Provider((ref) => CustomerRepository(ref.watch(dioProvider)));

class CustomerRepository {
  final Dio _dio;
  CustomerRepository(this._dio);

  Future<Map<String, dynamic>> getMyStatus() async {
    try {
      final response = await _dio.get('/customers/my-status');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener datos');
    }
  }

  Future<void> payInvoice({
    required String invoiceId,
    required double amount,
  }) async {
    try {
      // Llamamos al endpoint POST formal de pagos
      await _dio.post('/payments', data: {
        'invoiceId': invoiceId,
        'amount': amount,
        'method': 'QR', // Simulación para la app móvil
        'reference': 'SIM-MOB-${DateTime.now().millisecondsSinceEpoch}',
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Error al procesar el pago formal');
    }
  }
}
