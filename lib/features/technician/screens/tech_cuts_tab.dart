import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/technician/repositories/cut_repository.dart';
import 'package:elapas_app/features/technician/repositories/upload_repository.dart';
import 'package:elapas_app/core/services/sensor_service.dart';

class TechCutsTab extends ConsumerStatefulWidget {
  const TechCutsTab({super.key});

  @override
  ConsumerState<TechCutsTab> createState() => _TechCutsTabState();
}

class _TechCutsTabState extends ConsumerState<TechCutsTab> {
  bool _isLoading = true;
  List<dynamic> _cuts = [];
  final SensorService _sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    _loadCuts();
  }

  Future<void> _loadCuts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(cutRepositoryProvider);
      final cuts = await repo.getAssignedCuts();
      setState(() => _cuts = cuts);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _executeCut(String cutId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Corte'),
        content: const Text(
            '¿Has realizado el corte físico y tienes la evidencia lista?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('EJECUTAR')),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);

    try {
      // 1. Sensores
      final position = await _sensorService.getCurrentLocation();
      final photoFile = await _sensorService.takePhoto();

      final double lat = position?.latitude ?? -19.03332;
      final double lng = position?.longitude ?? -65.26274;
      String finalPhotoUrl =
          "https://via.placeholder.com/600x400.png?text=Evidencia+Corte+ELAPAS";

      // 2. Subida Real
      if (photoFile != null) {
        finalPhotoUrl =
            await ref.read(uploadRepositoryProvider).uploadImage(photoFile);
      }

      // 3. Backend
      await ref.read(cutRepositoryProvider).executeCut(
            cutId: cutId,
            lat: lat,
            lng: lng,
            photoUrl: finalPhotoUrl,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Corte registrado con éxito'),
          backgroundColor: Colors.green));
      _loadCuts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fallo: $e'), backgroundColor: Colors.red));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Órdenes de Corte',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: _loadCuts,
                    icon: const Icon(LucideIcons.refreshCw, size: 20)),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_cuts.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text('No hay cortes pendientes.',
                          style: TextStyle(color: Colors.grey))))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _cuts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final cut = _cuts[index];
                    return _buildCutItem(cut);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutItem(dynamic cut) {
    final customer = cut['customer'];
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(customer?['ci'] ?? '-',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      letterSpacing: 1.5)),
              const Icon(LucideIcons.scissors, color: Colors.red, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(customer?['fullName'] ?? 'Cliente',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(customer?['address'] ?? 'Dirección',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red)),
              onPressed: _isLoading ? null : () => _executeCut(cut['id']),
              child: const Text('MARCAR COMO EJECUTADO'),
            ),
          )
        ],
      ),
    );
  }
}
