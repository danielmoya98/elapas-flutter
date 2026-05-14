import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/auth/providers/auth_provider.dart';

class TechProfileTab extends ConsumerWidget {
  const TechProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const BouncingScrollPhysics(),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Center(
                  child: Icon(LucideIcons.user,
                      size: 32, color: Color(0xFF0F172A))),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(authState.email?.split('@')[0].toUpperCase() ?? 'TÉCNICO',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(authState.email ?? 'tecnico@elapas.com',
                    style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontFamily: 'monospace',
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text('SISTEMA',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                _buildProfileOption(
                    context, LucideIcons.shieldCheck, 'Seguridad y Contraseña'),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildProfileOption(context, LucideIcons.helpCircle,
                    'Soporte Técnico Operativo'),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildProfileOption(
                    context, LucideIcons.info, 'Versión de la App (v1.0.0)'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  foregroundColor: const Color(0xFFE11D48),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(LucideIcons.logOut, size: 18),
              label: const Text('CERRAR SESIÓN',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A))),
      trailing: const Icon(LucideIcons.chevronRight,
          size: 16, color: Color(0xFFCBD5E1)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Función en desarrollo.'),
          backgroundColor: Color(0xFF0F172A))),
    );
  }
}
