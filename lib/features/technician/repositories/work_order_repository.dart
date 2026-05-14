import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elapas_app/core/network/dio_client.dart';

final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  return WorkOrderRepository(ref.watch(dioProvider));
});

class WorkOrderRepository {
  final Dio _dio;
  WorkOrderRepository(this._dio);

  // --- INSTALACIONES ---

  Future<List<dynamic>> getAssignedInstallations() async {
    try {
      final response =
          await _dio.get('/work-orders/assigned?type=INSTALLATION');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Error al cargar instalaciones');
    }
  }

  Future<void> executeInstallation({
    required String workOrderId,
    required String meterCode,
    required double lat,
    required double lng,
    required String photoUrl,
  }) async {
    try {
      await _dio.patch('/work-orders/$workOrderId/execute', data: {
        'meterCode': meterCode,
        'gpsLat': lat,
        'gpsLng': lng,
        'photoUrl': photoUrl,
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Error al registrar instalación');
    }
  }

  // --- LECTURAS (NUEVOS MÉTODOS) ---

  Future<List<dynamic>> getAssignedWorkOrders({String? type}) async {
    try {
      final typeQuery = type != null ? '?type=$type' : '';
      final response = await _dio.get('/work-orders/assigned$typeQuery');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cargar órdenes');
    }
  }

  Future<Map<String, dynamic>> executeReading({
    required String workOrderId,
    required double currentReading,
    required double lat,
    required double lng,
    required String photoUrl,
  }) async {
    try {
      final response =
          await _dio.patch('/work-orders/$workOrderId/execute-reading', data: {
        'currentReading': currentReading,
        'gpsLat': lat,
        'gpsLng': lng,
        'photoUrl': photoUrl,
      });
      // Retornamos toda la data porque incluye alertas de fuga (isLeakAlert)
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Error al registrar lectura');
    }
  }

  // 🔥 NUEVO: EJECUTAR CORTE
  Future<void> executeCut(
      {required String workOrderId,
      required double lat,
      required double lng,
      required String photoUrl}) async {
    try {
      await _dio.patch('/work-orders/$workOrderId/execute-cut',
          data: {'gpsLat': lat, 'gpsLng': lng, 'photoUrl': photoUrl});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error');
    }
  }
}
