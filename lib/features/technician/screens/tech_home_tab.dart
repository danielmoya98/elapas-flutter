import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/auth/providers/auth_provider.dart';
import 'package:elapas_app/features/technician/repositories/cut_repository.dart';
import 'package:elapas_app/features/technician/repositories/work_order_repository.dart';

class TechHomeTab extends ConsumerStatefulWidget {
  const TechHomeTab({super.key});

  @override
  ConsumerState<TechHomeTab> createState() => _TechHomeTabState();
}

class _TechHomeTabState extends ConsumerState<TechHomeTab> {
  bool _isLoading = true;
  int _cutsCount = 0;
  int _installCount = 0;
  int _readingsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final workOrderRepo = ref.read(workOrderRepositoryProvider);

      final results = await Future.wait([
        ref.read(cutRepositoryProvider).getAssignedCuts(),
        workOrderRepo.getAssignedWorkOrders(type: 'INSTALLATION'),
        workOrderRepo.getAssignedWorkOrders(type: 'READING'),
      ]);

      if (mounted) {
        setState(() {
          _cutsCount = (results[0] as List).length;
          _installCount = (results[1] as List).length;
          _readingsCount = (results[2] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final String email = authState.email ?? 'tecnico@elapas.com';
    final String firstName = email.split('@')[0];
    final int totalTasks = _cutsCount + _installCount + _readingsCount;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF0F172A),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildHeader(firstName),
            const SizedBox(height: 32),
            if (_isLoading)
              _buildSkeletonLoader()
            else
              _buildStatusCard(
                  context,
                  'Resumen de Jornada',
                  '$totalTasks tareas pendientes hoy',
                  LucideIcons.clipboardList,
                  totalTasks > 0,
                  _cutsCount,
                  _installCount,
                  _readingsCount),
            const SizedBox(height: 40),
            const Text('ACCIONES RÁPIDAS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            _buildQuickAction(context, 'Reportar Incidencia',
                LucideIcons.alertTriangle, const Color(0xFFF59E0B)),
            _buildQuickAction(context, 'Ver Mapa de Ruta', LucideIcons.map,
                const Color(0xFF0284C7)),
            _buildQuickAction(context, 'Sincronizar Datos',
                LucideIcons.refreshCcw, const Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TÉCNICO OPERATIVO',
                style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text('Hola, ${firstName[0].toUpperCase()}${firstName.substring(1)}',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                    color: Color(0xFF0F172A))),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12)),
          child: const Center(
              child: Icon(LucideIcons.user, color: Colors.white, size: 24)),
        )
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, String subtitle,
      IconData icon, bool hasWork, int cuts, int installs, int readings) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: hasWork ? const Color(0xFF0F172A) : const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color:
                  (hasWork ? const Color(0xFF0F172A) : const Color(0xFF10B981))
                      .withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8))
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
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(hasWork ? 'EN SERVICIO' : 'RUTA LIBRE',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0)),
              ),
              Icon(icon, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(subtitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          if (hasWork) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.white24, height: 1),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildSubTaskInfo(LucideIcons.wrench, '$installs Instalaciones',
                    const Color(0xFF38BDF8)),
                _buildSubTaskInfo(LucideIcons.scanLine, '$readings Lecturas',
                    const Color(0xFFA78BFA)),
                _buildSubTaskInfo(LucideIcons.scissors, '$cuts Cortes',
                    const Color(0xFFFB7185)),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildSubTaskInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQuickAction(
      BuildContext context, String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Icon(icon, color: color, size: 18)),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF0F172A))),
        trailing: const Icon(LucideIcons.chevronRight,
            size: 16, color: Color(0xFFCBD5E1)),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Función disponible próximamente.'),
            backgroundColor: Color(0xFF0F172A))),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
        height: 180,
        decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16)));
  }
}
