import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/auth/providers/auth_provider.dart';
import 'package:elapas_app/features/technician/repositories/cut_repository.dart';

class TechHomeTab extends ConsumerWidget {
  const TechHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    // Usamos un FutureProvider ad-hoc para contar los cortes pendientes
    final cutsCountAsync = ref.watch(cutRepositoryProvider).getAssignedCuts();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildHeader(authState.email ?? 'Técnico'),
          const SizedBox(height: 32),
          FutureBuilder(
            future: cutsCountAsync,
            builder: (context, snapshot) {
              final count =
                  snapshot.hasData ? (snapshot.data as List).length : 0;
              return _buildStatusCard(context, 'Ruta Activa: Sucre Central',
                  '$count cortes pendientes hoy', LucideIcons.mapPin);
            },
          ),
          const SizedBox(height: 24),
          const Text('Acciones Rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildQuickAction(context, 'Reportar Incidencia',
              LucideIcons.alertTriangle, Colors.orange),
          _buildQuickAction(
              context, 'Ver Mapa de Ruta', LucideIcons.map, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildHeader(String email) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido,',
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            Text(email.split('@')[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1)),
          ],
        ),
        const CircleAvatar(
            backgroundColor: Colors.black12,
            child: Icon(LucideIcons.user, color: Colors.black)),
      ],
    );
  }

  Widget _buildStatusCard(
      BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          Text(subtitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(LucideIcons.chevronRight, size: 18),
        onTap: () {},
      ),
    );
  }
}
