import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/customer_repository.dart';

class CustomerInvoicesTab extends ConsumerStatefulWidget {
  const CustomerInvoicesTab({super.key});

  @override
  ConsumerState<CustomerInvoicesTab> createState() =>
      _CustomerInvoicesTabState();
}

class _CustomerInvoicesTabState extends ConsumerState<CustomerInvoicesTab> {
  bool _isProcessing = false;

  // Función corregida: ahora recibe el mapa completo de la factura
  Future<void> _processPayment(Map<String, dynamic> invoice) async {
    setState(() => _isProcessing = true);
    try {
      final String invoiceId = invoice['id'];

      // Conversión segura de num a double para el monto
      final double amount = invoice['total'] is int
          ? (invoice['total'] as int).toDouble()
          : (invoice['total'] as double);

      // Llamada al repositorio con los datos requeridos por el backend
      await ref.read(customerRepositoryProvider).payInvoice(
            invoiceId: invoiceId,
            amount: amount,
          );

      if (!mounted) return;
      Navigator.pop(context); // Cierra el modal de detalle

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Pago registrado y factura liquidada con éxito!'),
            backgroundColor: Colors.green),
      );

      // Invalida el provider para refrescar la lista de facturas
      ref.invalidate(customerRepositoryProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showInvoiceModal(BuildContext context, Map<String, dynamic> invoice) {
    final bool isPaid = invoice['status'] == 'PAGADO';
    final double amount = invoice['total'] is int
        ? (invoice['total'] as int).toDouble()
        : invoice['total'];
    final String id = invoice['id'].toString().substring(0, 8).toUpperCase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(builder: (context, setStateModal) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isPaid ? 'RECIBO DIGITAL' : 'DETALLE DE PAGO',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 12,
                            color: Colors.grey)),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text('Bs ${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              letterSpacing: -2)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          invoice['status'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPaid ? Colors.green : Colors.orange,
                              fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow('Factura Nº', id),
                _buildDetailRow('Concepto', 'Servicio de Agua Potable'),
                _buildDetailRow(
                    'Periodo', invoice['createdAt'].toString().split('T')[0]),
                _buildDetailRow('Titular', 'ELAPAS Sucre'),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPaid ? Colors.black : const Color(0xFF0052FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: _isProcessing
                        ? null
                        : () {
                            if (isPaid) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Descargando PDF del recibo...'),
                                      backgroundColor: Colors.black));
                              Navigator.pop(context);
                            } else {
                              // CORRECCIÓN: Ahora pasamos el objeto 'invoice' completo
                              _processPayment(invoice);
                            }
                          },
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(isPaid
                            ? LucideIcons.printer
                            : LucideIcons.creditCard),
                    label: Text(
                      _isProcessing
                          ? 'PROCESANDO...'
                          : (isPaid ? 'IMPRIMIR RECIBO' : 'PAGAR AHORA'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(customerRepositoryProvider).getMyStatus();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HISTORIAL',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            const Text('Facturas',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.2)),
            const SizedBox(height: 32),
            Expanded(
              child: FutureBuilder(
                future: statusAsync,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.black));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data as Map<String, dynamic>;
                  final List invoices = data['invoices'] ?? [];

                  if (invoices.isEmpty) {
                    return const Center(
                        child: Text('No hay facturas registradas.',
                            style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.separated(
                    itemCount: invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final inv = invoices[index];
                      final bool isPaid = inv['status'] == 'PAGADO';
                      final double amount = inv['total'] is int
                          ? (inv['total'] as int).toDouble()
                          : inv['total'];

                      return InkWell(
                        onTap: () => _showInvoiceModal(context, inv),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: isPaid
                                    ? Colors.black12
                                    : Colors.orange.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  isPaid
                                      ? LucideIcons.fileCheck
                                      : LucideIcons.alertCircle,
                                  color: isPaid ? Colors.black : Colors.orange),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Factura #${inv['id'].toString().substring(0, 8).toUpperCase()}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        'Fecha: ${inv['createdAt'].toString().split('T')[0]}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Bs ${amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace')),
                                  Text(inv['status'],
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isPaid
                                              ? Colors.black45
                                              : Colors.orange)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
