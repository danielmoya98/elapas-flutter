import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/technician/repositories/work_order_repository.dart';
import 'package:elapas_app/features/technician/repositories/upload_repository.dart';
import 'package:elapas_app/core/services/sensor_service.dart';

class TechCutsTab extends ConsumerStatefulWidget {
  const TechCutsTab({super.key});

  @override
  ConsumerState<TechCutsTab> createState() => _TechCutsTabState();
}

class _TechCutsTabState extends ConsumerState<TechCutsTab> {
  bool _isLoading = true;
  List<dynamic> _cutOrders = [];
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
      final repo = ref.read(workOrderRepositoryProvider);
      // 🔥 Consumimos las órdenes de tipo 'CUT' (Corte)
      final data = await repo.getAssignedWorkOrders(type: 'CUT');
      setState(() => _cutOrders = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFE11D48)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _executeCut(String workOrderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertOctagon, color: Color(0xFFE11D48)),
            SizedBox(width: 8),
            Text('Confirmar Corte',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
        content: const Text(
            '¿Has realizado el corte físico, colocado el precinto y tienes la evidencia lista?',
            style: TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR',
                  style: TextStyle(
                      color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('EJECUTAR CORTE',
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
          "https://via.placeholder.com/600x400.png?text=Evidencia+Corte+ELAPAS";

      if (photoFile != null) {
        finalPhotoUrl =
            await ref.read(uploadRepositoryProvider).uploadImage(photoFile);
      }

      // Llamamos al método especializado para ejecutar cortes en el WorkOrderRepository
      await ref.read(workOrderRepositoryProvider).executeCut(
            workOrderId: workOrderId,
            lat: lat,
            lng: lng,
            photoUrl: finalPhotoUrl,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Corte registrado exitosamente. Cliente suspendido.'),
          backgroundColor: Color(0xFF10B981)));
      _loadCuts();
    } catch (e) {
      if (!mounted) return;
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
                    const Text('URGENTE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Color(0xFFE11D48))),
                    const SizedBox(height: 4),
                    const Text('Cortes por Mora',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.0,
                            color: Color(0xFF0F172A))),
                  ],
                ),
                IconButton(
                    onPressed: _loadCuts,
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
            else if (_cutOrders.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text('No tienes órdenes de corte asignadas.',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500))))
            else
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cutOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildCutItem(_cutOrders[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutItem(dynamic order) {
    final customer = order['customer'];
    final meter = order['meter'];

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
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('MD: ${meter?['code'] ?? '-'}',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE11D48),
                        letterSpacing: 1.0)),
              ),
              const Icon(LucideIcons.scissors,
                  color: Color(0xFFE11D48), size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(customer?['fullName'] ?? 'Cliente',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(customer?['address'] ?? 'Dirección',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Color(0xFFE2E8F0), height: 1)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE11D48),
                side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isLoading ? null : () => _executeCut(order['id']),
              child: const Text('MARCAR COMO EJECUTADO',
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
