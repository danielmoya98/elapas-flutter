import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/auth/providers/auth_provider.dart'; // Ajusta la ruta si es necesario
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
          // 1. SKELETON LOADER (Efecto de carga Premium)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar perfil:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE11D48)),
              ),
            );
          }

          final data = snapshot.data as Map<String, dynamic>;
          final String fullName = data['fullName'] ?? 'Usuario';
          final String address = data['address'] ?? 'Sin dirección registrada';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              // --- CABECERA DE PERFIL ---
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC), // canvas
                    border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2), // border-soft
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.email ?? '',
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontFamily: 'monospace',
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- SECCIÓN DE CONFIGURACIÓN ---
              const Text(
                'CONFIGURACIÓN',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // Opciones agrupadas en una tarjeta
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildOption(
                      context,
                      LucideIcons.mapPin,
                      'Dirección de Suministro',
                      subtitle: address,
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    _buildOption(
                      context,
                      LucideIcons.creditCard,
                      'Métodos de Pago',
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    _buildOption(
                      context,
                      LucideIcons.shieldCheck,
                      'Seguridad de la cuenta',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- BOTÓN DE CERRAR SESIÓN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2), // rose-50
                      foregroundColor: const Color(0xFFE11D48), // rose-600
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: const Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildOption(BuildContext context, IconData icon, String title,
      {String? subtitle}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A)),
      ),
      subtitle: subtitle != null && subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500),
            )
          : null,
      trailing: const Icon(LucideIcons.chevronRight,
          size: 16, color: Color(0xFFCBD5E1)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración disponible próximamente.'),
            backgroundColor: Color(0xFF0F172A),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(width: 150, height: 20, color: const Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              Container(width: 200, height: 14, color: const Color(0xFFE2E8F0)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Container(width: 100, height: 12, color: const Color(0xFFE2E8F0)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
