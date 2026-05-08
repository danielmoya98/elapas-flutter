import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SensorService {
  final ImagePicker _picker = ImagePicker();

  // Obtener coordenadas GPS
  Future<Position?> getCurrentLocation() async {
    try {
      // En dispositivos reales pedirá permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Si estamos en Linux/Emulador y falla, devolverá null o error
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      print('GPS no disponible en este dispositivo (Linux/Emulador)');
      return null;
    }
  }

  // Tomar fotografía
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Comprimir para no saturar el backend
      );
      if (photo != null) return File(photo.path);
      return null;
    } catch (e) {
      print('Cámara no disponible en este dispositivo');
      return null;
    }
  }
}
