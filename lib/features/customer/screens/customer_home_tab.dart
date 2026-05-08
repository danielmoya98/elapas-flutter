import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/customer_repository.dart';

class CustomerHomeTab extends ConsumerWidget {
  const CustomerHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el repositorio del cliente
    final statusAsync = ref.watch(customerRepositoryProvider).getMyStatus();

    return SafeArea(
      child: FutureBuilder(
        future: statusAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar datos: ${snapshot.error}'));
          }

          final data = snapshot.data as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeader(data['fullName'] ?? 'Usuario'),
              const SizedBox(height: 32),

              // Tarjeta de Deuda
              _buildDebtCard(context, data['totalDebt'] ?? 0.0,
                  data['pendingInvoices'] ?? 0),

              const SizedBox(height: 32),
              const Text('Mis Medidores',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),

              // Lista de medidores vinculados en la BD
              ...(data['meters'] as List)
                  .map((m) => _buildMeterTile(m))
                  .toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado de Cuenta',
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14)),
        Text(name,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
      ],
    );
  }

  Widget _buildDebtCard(BuildContext context, dynamic debt, int invoices) {
    final bool hasDebt = debt > 0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: hasDebt ? Colors.black : Colors.blueAccent[700],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: (hasDebt ? Colors.black : Colors.blueAccent)
                    .withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hasDebt ? 'DEUDA PENDIENTE' : 'AL DÍA',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const Icon(LucideIcons.droplets, color: Colors.white24),
            ],
          ),
          const SizedBox(height: 12),
          Text('Bs ${debt.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
          const SizedBox(height: 8),
          Text('$invoices facturas pendientes de pago',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (hasDebt) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {/* Lógica de pasarela de pago */},
                child: const Text('PAGAR AHORA',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildMeterTile(Map<String, dynamic> meter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.gauge, size: 24, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medidor: ${meter['code']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Consumo actual: ${meter['lastReading']} m³',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Colors.black26),
        ],
      ),
    );
  }
}
