import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
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
          // 1. SKELETON LOADER (Efecto premium de carga)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.alertTriangle,
                        color: Color(0xFFE11D48), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error de conexión\n${snapshot.error.toString().replaceAll('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data as Map<String, dynamic>;
          final fullName = data['fullName'] ?? 'Usuario';
          final firstName = fullName.split(' ')[0];

          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(customerRepositoryProvider).getMyStatus(),
            color: const Color(0xFF0F172A),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // HEADER PERSONALIZADO
                _buildHeader(fullName, firstName),
                const SizedBox(height: 32),

                // TARJETA DE DEUDA DINÁMICA
                _buildDebtCard(context, data['totalDebt'] ?? 0.0,
                    data['pendingInvoices'] ?? 0),
                const SizedBox(height: 32),

                // ACCIONES RÁPIDAS (Relleno UI)
                _buildQuickActions(context),
                const SizedBox(height: 40),

                // TÍTULO MEDIDORES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MIS MEDIDORES',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Color(0xFF64748B)),
                    ),
                    Icon(LucideIcons.radioReceiver,
                        size: 14,
                        color: const Color(0xFF10B981).withOpacity(0.8)),
                  ],
                ),
                const SizedBox(height: 16),

                // LISTA DE MEDIDORES
                if (data['meters'] != null &&
                    (data['meters'] as List).isNotEmpty)
                  ...(data['meters'] as List)
                      .map((m) => _buildMeterTile(context, m))
                      .toList()
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Center(
                      child: Text('No hay medidores vinculados a su cuenta.',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 13)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader(String fullName, String firstName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BIENVENIDO',
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Hola, $firstName',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                  color: Color(0xFF0F172A)),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDebtCard(BuildContext context, dynamic debt, int invoices) {
    final bool hasDebt = debt > 0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: hasDebt ? const Color(0xFF0F172A) : Colors.white,
        border: Border.all(
            color: hasDebt ? Colors.transparent : const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: hasDebt
                  ? const Color(0xFF0F172A).withOpacity(0.25)
                  : Colors.black.withOpacity(0.03),
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
                  color: hasDebt
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hasDebt ? 'DEUDA PENDIENTE' : 'SERVICIOS AL DÍA',
                  style: TextStyle(
                      color: hasDebt ? Colors.white : const Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0),
                ),
              ),
              Icon(LucideIcons.droplets,
                  color: hasDebt
                      ? Colors.white24
                      : const Color(0xFF10B981).withOpacity(0.3),
                  size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Bs ${debt.toStringAsFixed(2)}',
            style: TextStyle(
                color: hasDebt ? Colors.white : const Color(0xFF0F172A),
                fontSize: 44,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: -2),
          ),
          const SizedBox(height: 8),
          Text(
            hasDebt
                ? '$invoices facturas pendientes de pago'
                : 'Gracias por su puntualidad en los pagos.',
            style: TextStyle(
                color: hasDebt ? Colors.white70 : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          if (hasDebt) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Dirígete a la pestaña de Facturas para pagar.'),
                        backgroundColor: Color(0xFF0F172A)),
                  );
                },
                child: const Text('PAGAR AHORA',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCIONES RÁPIDAS',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildActionChip(context, LucideIcons.alertOctagon,
                  'Reportar Fuga', const Color(0xFFF59E0B)),
              const SizedBox(width: 12),
              _buildActionChip(context, LucideIcons.mapPin, 'Puntos de Pago',
                  const Color(0xFF0284C7)),
              const SizedBox(width: 12),
              // CORRECCIÓN 1: LucideIcons.headphones en lugar de headset
              _buildActionChip(context, LucideIcons.headphones, 'Soporte',
                  const Color(0xFF8B5CF6)),
              const SizedBox(width: 12),
              _buildActionChip(context, LucideIcons.fileText, 'Requisitos',
                  const Color(0xFF64748B)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(
      BuildContext context, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$label: Función disponible próximamente.'),
              backgroundColor: const Color(0xFF0F172A),
              duration: const Duration(seconds: 2)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }

  Widget _buildMeterTile(BuildContext context, Map<String, dynamic> meter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Icon(LucideIcons.gauge,
                        size: 24, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MEDIDOR ${meter['code']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('ACTIVO • Transmitiendo',
                              style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.calculator,
                    color: Color(0xFF64748B)),
                tooltip: 'Simular',
                onPressed: () {
                  double lastRead = (meter['lastReading'] as num).toDouble();
                  _showSimulatorModal(context, lastRead);
                },
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFE2E8F0), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Última Lectura Registrada',
                  style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text('${meter['lastReading']} m³',
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de Consumo Histórico
          if (meter['consumptionHistory'] != null)
            ConsumptionChart(history: meter['consumptionHistory']),
        ],
      ),
    );
  }

  // --- MODAL SIMULADOR ---
  void _showSimulatorModal(BuildContext context, double lastReading) {
    double inputReading = lastReading;
    const double costPerM3 = 2.50; // Tarifa referencial

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(builder: (context, setStateModal) {
        final double consumption = inputReading - lastReading;
        final double estimatedCost =
            consumption > 0 ? consumption * costPerM3 : 0;

        return Padding(
          // CORRECCIÓN 2: Sumamos el padding directamente
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            left: 32,
            right: 32,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SIMULADOR DE CONSUMO',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 10,
                          color: Color(0xFF64748B))),
                  IconButton(
                      icon: const Icon(LucideIcons.x,
                          size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                  'Ingrese la lectura actual de su medidor físico para estimar su próxima factura.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
              const SizedBox(height: 32),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'Lectura Actual (m³)',
                  hintText: lastReading.toString(),
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF0F172A), width: 2)),
                ),
                onChanged: (value) {
                  setStateModal(() {
                    inputReading = double.tryParse(value) ?? lastReading;
                  });
                },
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Consumo proyectado',
                            style: TextStyle(color: Color(0xFF94A3B8))),
                        Text(
                            '${consumption > 0 ? consumption.toStringAsFixed(1) : 0} m³',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace')),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Estimado',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Text('Bs ${estimatedCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // --- SKELETON LOADER ---
  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 100, height: 12, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Container(
                    width: 180, height: 28, color: const Color(0xFFE2E8F0)),
              ],
            ),
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12))),
          ],
        ),
        const SizedBox(height: 32),
        Container(
            height: 200,
            decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16))),
        const SizedBox(height: 40),
        Container(width: 120, height: 12, color: const Color(0xFFE2E8F0)),
        const SizedBox(height: 16),
        Container(
            height: 250,
            decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16))),
      ],
    );
  }
}

// --- GRÁFICO DE CONSUMO ---
class ConsumptionChart extends StatelessWidget {
  final List<dynamic> history;

  const ConsumptionChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final chartData = history.take(6).toList().reversed.toList();

    if (chartData.isEmpty) return const SizedBox();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 24, right: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxValue(chartData) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= chartData.length)
                    return const SizedBox();
                  final dateStr = chartData[value.toInt()]['date'].toString();
                  final month = dateStr.split('-')[1];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('M$month',
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            chartData.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (chartData[i]['value'] as num).toDouble(),
                  color: i == chartData.length - 1
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFE2E8F0),
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxValue(List<dynamic> data) {
    double max = 0;
    for (var item in data) {
      if ((item['value'] as num).toDouble() > max)
        max = (item['value'] as num).toDouble();
    }
    return max == 0 ? 100 : max;
  }
}
