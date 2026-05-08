import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/technician/repositories/reading_repository.dart';
import 'package:elapas_app/features/technician/repositories/upload_repository.dart';
import 'package:elapas_app/core/services/sensor_service.dart';

class TechReadingsTab extends ConsumerStatefulWidget {
  const TechReadingsTab({super.key});

  @override
  ConsumerState<TechReadingsTab> createState() => _TechReadingsTabState();
}

class _TechReadingsTabState extends ConsumerState<TechReadingsTab> {
  final _searchController = TextEditingController();
  final _readingController = TextEditingController();
  final SensorService _sensorService = SensorService();

  bool _isLoading = false;
  Map<String, dynamic>? _currentMeter;

  Future<void> _searchMeter() async {
    if (_searchController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(readingRepositoryProvider);
      final meter = await repo
          .getMeterByCode(_searchController.text.trim().toUpperCase());
      setState(() => _currentMeter = meter);
      _readingController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red));
      setState(() => _currentMeter = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReading() async {
    if (_readingController.text.isEmpty || _currentMeter == null) return;

    // Validación básica de entrada
    final double? newValue = double.tryParse(_readingController.text);
    if (newValue == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Obtener evidencia física (GPS y Foto)
      final position = await _sensorService.getCurrentLocation();
      final photoFile = await _sensorService.takePhoto();

      final double lat = position?.latitude ?? -19.03332;
      final double lng = position?.longitude ?? -65.26274;

      // Fallback por si no hay foto (ej. desarrollo en Linux)
      String finalPhotoUrl =
          "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg";

      // 2. Subida real si se capturó la imagen
      if (photoFile != null) {
        finalPhotoUrl =
            await ref.read(uploadRepositoryProvider).uploadImage(photoFile);
      }

      // 3. Enviar al backend
      final repo = ref.read(readingRepositoryProvider);
      await repo.submitReading(
        meterId: _currentMeter!['id'],
        currentReading: newValue,
        lat: lat,
        lng: lng,
        photoUrl: finalPhotoUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lectura y evidencia enviadas correctamente'),
          backgroundColor: Colors.green));

      setState(() => _currentMeter = null);
      _searchController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Registro de Lectura',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Medidor',
                      hintText: 'Ej. M-10023',
                      prefixIcon: Icon(LucideIcons.hash),
                    ),
                    onSubmitted: (_) => _searchMeter(),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _isLoading ? null : _searchMeter,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(LucideIcons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_currentMeter != null) ...[
              _buildMeterCard(),
              const SizedBox(height: 24),
              TextField(
                controller: _readingController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Nueva Lectura (m³)',
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitReading,
                icon: const Icon(LucideIcons.camera),
                label: const Text('CAPTURAR Y ENVIAR'),
              ),
            ] else if (!_isLoading) ...[
              const Expanded(
                  child: Center(
                      child: Text(
                          'Ingrese un código de medidor\npara iniciar el registro.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey)))),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMeterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DATOS DEL CLIENTE',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(_currentMeter!['customerName'] ?? 'Sin Nombre',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(_currentMeter!['address'] ?? 'Sin Dirección',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lectura Anterior:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${_currentMeter!['previousReading']} m³',
                  style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
