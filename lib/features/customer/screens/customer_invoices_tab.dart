import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../repositories/customer_repository.dart'; // Ajusta esta ruta si es diferente en tu proyecto

class CustomerInvoicesTab extends ConsumerStatefulWidget {
  const CustomerInvoicesTab({super.key});

  @override
  ConsumerState<CustomerInvoicesTab> createState() =>
      _CustomerInvoicesTabState();
}

class _CustomerInvoicesTabState extends ConsumerState<CustomerInvoicesTab> {
  bool _isProcessing = false;

  Future<void> _processPayment(Map<String, dynamic> invoice) async {
    setState(() => _isProcessing = true);
    try {
      final String invoiceId = invoice['id'];

      final double amount = invoice['total'] is int
          ? (invoice['total'] as int).toDouble()
          : (invoice['total'] as double);

      // 🔥 MAGIA UI: Simulamos la generación y validación del código QR Simple
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generando código QR y contactando al banco...'),
          backgroundColor: Color(0xFF0F172A), // Slate-900
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2)); // Retraso artificial

      // Llamada real al backend
      await ref.read(customerRepositoryProvider).payInvoice(
            invoiceId: invoiceId,
            amount: amount,
          );

      if (!mounted) return;
      Navigator.pop(context); // Cierra el modal de detalle

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Pago QR validado y factura liquidada con éxito!'),
            backgroundColor: Color(0xFF10B981)), // Emerald-500
      );

      // Refresca la lista
      ref.invalidate(customerRepositoryProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFE11D48)), // Rose-600
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- COMPONENTES UI PREMIUM ---

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'PAGADO':
        bgColor = const Color(0xFF10B981).withOpacity(0.1);
        textColor = const Color(0xFF059669);
        break;
      case 'VENCIDO':
        bgColor = const Color(0xFFF43F5E).withOpacity(0.1);
        textColor = const Color(0xFFE11D48);
        break;
      default: // PENDIENTE
        bgColor = const Color(0xFFF59E0B).withOpacity(0.1);
        textColor = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: textColor,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0),
      ),
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
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 120, height: 14, color: const Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),
                    Container(
                        width: 80, height: 10, color: const Color(0xFFE2E8F0)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: 80, height: 18, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  Container(
                      width: 60, height: 16, color: const Color(0xFFE2E8F0)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- MODAL PREMIUM ---

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
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              left: 32,
              right: 32,
              top: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPaid ? 'RECIBO DIGITAL' : 'DETALLE DE PAGO',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 10,
                        color: Color(0xFF64748B)),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x,
                        size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Bs ${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: -2,
                          color: isPaid
                              ? const Color(0xFF10B981)
                              : const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(invoice['status']),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              _buildDetailRow('Factura Nº', '#$id'),
              _buildDetailRow('Concepto', 'Servicio de Agua Potable'),
              _buildDetailRow(
                  'Periodo', invoice['createdAt'].toString().split('T')[0]),
              _buildDetailRow('Titular', 'ELAPAS Sucre'),
              const SizedBox(height: 40),

              // Botón de Acción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isPaid
                          ? const Color(0xFFF1F5F9)
                          : const Color(
                              0xFF0284C7), // Azul vibrante para pagar QR
                      foregroundColor:
                          isPaid ? const Color(0xFF0F172A) : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: _isProcessing
                      ? null
                      : () {
                          if (isPaid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Descargando PDF del recibo...'),
                                  backgroundColor: Color(0xFF0F172A)),
                            );
                            Navigator.pop(context);
                          } else {
                            _processPayment(invoice);
                          }
                        },
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(isPaid ? LucideIcons.printer : LucideIcons.qrCode,
                          size: 18),
                  label: Text(
                    _isProcessing
                        ? 'CONECTANDO CON BANCO...'
                        : (isPaid ? 'IMPRIMIR RECIBO' : 'PAGAR CON QR SIMPLE'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // --- VISTA PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(customerRepositoryProvider).getMyStatus();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HISTORIAL',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mis Facturas',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder(
                future: statusAsync,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildSkeletonLoader();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Color(0xFFE11D48))),
                    );
                  }

                  final data = snapshot.data as Map<String, dynamic>;
                  final List invoices = data['invoices'] ?? [];

                  if (invoices.isEmpty) {
                    return const Center(
                      child: Text('No hay facturas registradas en el sistema.',
                          style: TextStyle(color: Color(0xFF64748B))),
                    );
                  }

                  return ListView.separated(
                    itemCount: invoices.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final inv = invoices[index];
                      final bool isPaid = inv['status'] == 'PAGADO';
                      final double amount = inv['total'] is int
                          ? (inv['total'] as int).toDouble()
                          : inv['total'];
                      final String idShort =
                          inv['id'].toString().substring(0, 8).toUpperCase();

                      return InkWell(
                        onTap: () => _showInvoiceModal(context, inv),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(
                                  isPaid
                                      ? LucideIcons.fileCheck
                                      : LucideIcons.fileText,
                                  color: isPaid
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF64748B),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Factura #$idShort',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      inv['createdAt'].toString().split('T')[0],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontFamily: 'monospace'),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Bs ${amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        fontSize: 16,
                                        color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildStatusBadge(inv['status']),
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
