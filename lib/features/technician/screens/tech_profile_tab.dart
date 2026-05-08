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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black12,
              child: Icon(LucideIcons.user, size: 50, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Text(authState.email ?? 'tecnico@elapas.com',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Técnico Operativo - ELAPAS',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildProfileOption(LucideIcons.shieldCheck, 'Cambiar Contraseña'),
            _buildProfileOption(LucideIcons.helpCircle, 'Soporte Técnico'),
            _buildProfileOption(LucideIcons.info, 'Versión de la App (v1.0.0)'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(LucideIcons.logOut),
                label: const Text('CERRAR SESIÓN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
      onTap: () {},
    );
  }
}
