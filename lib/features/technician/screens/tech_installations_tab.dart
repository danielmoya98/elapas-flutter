import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/technician/repositories/work_order_repository.dart';
import 'package:elapas_app/features/technician/repositories/upload_repository.dart';
import 'package:elapas_app/core/services/sensor_service.dart';

class TechInstallationsTab extends ConsumerStatefulWidget {
  const TechInstallationsTab({super.key});

  @override
  ConsumerState<TechInstallationsTab> createState() =>
      _TechInstallationsTabState();
}

class _TechInstallationsTabState extends ConsumerState<TechInstallationsTab> {
  bool _isLoading = true;
  List<dynamic> _installations = [];
  final SensorService _sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    _loadInstallations();
  }

  Future<void> _loadInstallations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(workOrderRepositoryProvider);
      final data = await repo.getAssignedInstallations();
      setState(() => _installations = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFE11D48)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _executeInstallation(String workOrderId) async {
    final meterCodeController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Registrar Instalación',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Ingrese el código de serie del medidor físico que acaba de instalar:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: meterCodeController,
              decoration: InputDecoration(
                labelText: 'Código del Medidor',
                hintText: 'Ej. ELP-2026-X',
                prefixIcon: const Icon(LucideIcons.hash),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR',
                  style: TextStyle(
                      color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF0284C7), // Sky blue para instalaciones
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                if (meterCodeController.text.trim().isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('CONTINUAR',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white))),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);

    try {
      final position = await _sensorService.getCurrentLocation();
      final photoFile = await _sensorService.takePhoto();

      final double lat = position?.latitude ?? -19.03332;
      final double lng = position?.longitude ?? -65.26274;
      String finalPhotoUrl =
          "https://via.placeholder.com/600x400.png?text=Evidencia+Instalacion";

      if (photoFile != null) {
        finalPhotoUrl =
            await ref.read(uploadRepositoryProvider).uploadImage(photoFile);
      }

      await ref.read(workOrderRepositoryProvider).executeInstallation(
            workOrderId: workOrderId,
            meterCode: meterCodeController.text.trim().toUpperCase(),
            lat: lat,
            lng: lng,
            photoUrl: finalPhotoUrl,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Instalación registrada y cliente activado con éxito.'),
          backgroundColor: Color(0xFF10B981)));
      _loadInstallations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Fallo: $e'),
          backgroundColor: const Color(0xFFE11D48)));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NUEVOS SERVICIOS',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    const Text('Instalaciones',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.0,
                            color: Color(0xFF0F172A))),
                  ],
                ),
                IconButton(
                    onPressed: _loadInstallations,
                    icon: const Icon(LucideIcons.refreshCw,
                        size: 20, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Expanded(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF0F172A))))
            else if (_installations.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text('No tienes instalaciones pendientes hoy.',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500))))
            else
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _installations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildInstallationItem(_installations[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallationItem(dynamic order) {
    final customer = order['customer'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('NUEVO MEDIDOR',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0284C7),
                        letterSpacing: 1.0)),
              ),
              const Icon(LucideIcons.wrench,
                  color: Color(0xFF0284C7), size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(customer?['fullName'] ?? 'Cliente Nuevo',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(customer?['address'] ?? 'Dirección Pendiente',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          if (order['description'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(order['description'],
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)))),
                ],
              ),
            )
          ],
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Color(0xFFE2E8F0), height: 1)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed:
                  _isLoading ? null : () => _executeInstallation(order['id']),
              child: const Text('INSTALAR MEDIDOR',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }
}
