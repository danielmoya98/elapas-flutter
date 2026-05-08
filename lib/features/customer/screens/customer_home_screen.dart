import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../repositories/customer_repository.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del perfil del cliente desde el repositorio
    final statusAsync = ref.watch(customerRepositoryProvider).getMyStatus();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: statusAsync,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }

            final data = snapshot.data as Map<String, dynamic>;

            return RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(customerRepositoryProvider).getMyStatus(),
              color: Colors.black,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildHeader(data['fullName'] ?? 'Usuario'),
                  const SizedBox(height: 32),

                  // Tarjeta de Deuda (Visualización dinámica basada en estado)
                  _buildDebtCard(context, data['totalDebt'] ?? 0.0,
                      data['pendingInvoices'] ?? 0),

                  const SizedBox(height: 40),

                  const Text(
                    'MIS MEDIDORES',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Lista de medidores desde el backend
                  if (data['meters'] != null &&
                      (data['meters'] as List).isNotEmpty)
                    ...(data['meters'] as List)
                        .map((m) => _buildMeterTile(context, m))
                        .toList()
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No hay medidores vinculados a su cuenta.'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESTADO DE CUENTA',
          style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.2,
              color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDebtCard(BuildContext context, dynamic debt, int invoices) {
    final hasDebt = debt > 0;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: hasDebt
            ? Colors.black
            : const Color(0xFF0052FF), // Azul eléctrico suizo si está al día
        borderRadius: BorderRadius.circular(
            12), // Bordes menos redondeados para estilo más industrial
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasDebt ? 'DEUDA PENDIENTE' : 'SERVICIOS AL DÍA',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0),
              ),
              const Icon(LucideIcons.droplets, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Bs ${debt.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: -2),
          ),
          const SizedBox(height: 12),
          Text(
            hasDebt
                ? '$invoices facturas pendientes de pago'
                : 'Gracias por su puntualidad',
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          if (hasDebt) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)), // Estilo flat
                ),
                onPressed: () {
                  // TODO: Implementar pasarela de pago o redirigir a pestaña facturas
                },
                child: const Text(
                  'PAGAR AHORA',
                  style:
                      TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  void _showSimulatorModal(BuildContext context, double lastReading) {
    double inputReading = lastReading;
    // Tarifa referencial (idealmente traída del backend)
    const double costPerM3 = 2.50;

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
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 32,
              right: 32,
              top: 32,
              bottom: 40),
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
                          color: Colors.grey)),
                  IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                  'Ingrese la lectura actual de su medidor físico para estimar su próxima factura.',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),

              // Input de lectura
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'Lectura Actual (m³)',
                  hintText: lastReading.toString(),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
                onChanged: (value) {
                  setStateModal(() {
                    inputReading = double.tryParse(value) ?? lastReading;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Resultados en vivo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Consumo proyectado',
                            style: TextStyle(color: Colors.white70)),
                        Text(
                            '${consumption > 0 ? consumption.toStringAsFixed(1) : 0} m³',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Estimado',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text('Bs ${estimatedCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.greenAccent,
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

  Widget _buildMeterTile(BuildContext context, Map<String, dynamic> meter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.gauge, size: 24, color: Colors.black),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MEDIDOR ${meter['code']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5)),
                      Text('Lectura anterior: ${meter['lastReading']} m³',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.calculator,
                    color: Color(0xFF0052FF)),
                tooltip: 'Simular próxima factura',
                onPressed: () {
                  double lastRead = (meter['lastReading'] as num).toDouble();
                  _showSimulatorModal(context, lastRead);
                },
              )
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
}

// --- Widget del Gráfico de Consumo ---
class ConsumptionChart extends StatelessWidget {
  final List<dynamic> history;

  const ConsumptionChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // if (history.isEmpty) return const SizedBox();

    // Tomamos hasta 6 meses y los invertimos
    final chartData = history.take(6).toList().reversed.toList();

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
                  if (value.toInt() >= chartData.length) {
                    return const SizedBox();
                  }
                  final dateStr = chartData[value.toInt()]['date'].toString();
                  final month = dateStr.split('-')[1];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('M$month',
                        style: const TextStyle(
                            color: Colors.grey,
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
                      ? Colors.black
                      : Colors.black12, // Resaltar mes actual
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
      if ((item['value'] as num).toDouble() > max) {
        max = (item['value'] as num).toDouble();
      }
    }
    return max == 0 ? 100 : max;
  }
}
