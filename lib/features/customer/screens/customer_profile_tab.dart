import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/customer_repository.dart';

class CustomerProfileTab extends ConsumerWidget {
  const CustomerProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    // Traemos los datos del perfil desde el repositorio del cliente
    final profileAsync = ref.watch(customerRepositoryProvider).getMyStatus();

    return SafeArea(
      child: FutureBuilder(
          future: profileAsync,
          builder: (context, snapshot) {
            final String fullName = snapshot.hasData
                ? (snapshot.data as Map)['fullName']
                : 'Cargando...';

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child:
                        Icon(LucideIcons.user, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(fullName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5)),
                      Text(authState.email ?? '',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                _buildOption(
                    context, LucideIcons.mapPin, 'Dirección de Suministro',
                    subtitle: snapshot.hasData
                        ? (snapshot.data as Map)['address']
                        : ''),
                _buildOption(
                    context, LucideIcons.creditCard, 'Métodos de Pago'),
                _buildOption(
                    context, LucideIcons.shieldCheck, 'Seguridad de la cuenta'),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        elevation: 0,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.all(16)),
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    icon: const Icon(LucideIcons.logOut),
                    label: const Text('CERRAR SESIÓN',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title,
      {String? subtitle}) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      onTap: () {},
    );
  }
}
