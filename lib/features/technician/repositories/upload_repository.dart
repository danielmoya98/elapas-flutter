import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elapas_app/core/network/dio_client.dart';

final uploadRepositoryProvider =
    Provider((ref) => UploadRepository(ref.watch(dioProvider)));

class UploadRepository {
  final Dio _dio;
  UploadRepository(this._dio);

  Future<String> uploadImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // Llama a tu UploadsController en el backend
      final response = await _dio.post('/uploads', data: formData);
      return response.data['url']; // Retorna la URL real de Cloudinary
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Error al subir imagen a Cloudinary');
    }
  }
}
