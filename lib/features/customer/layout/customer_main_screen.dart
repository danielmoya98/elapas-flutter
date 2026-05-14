import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elapas_app/features/customer/screens/customer_home_tab.dart';
import 'package:elapas_app/features/customer/screens/customer_invoices_tab.dart';
import 'package:elapas_app/features/customer/screens/customer_profile_tab.dart';

class CustomerMainScreen extends ConsumerStatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const CustomerHomeTab(),
    const CustomerInvoicesTab(),
    const CustomerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // canvas background
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0F172A), // content-main
          unselectedItemColor: const Color(0xFF94A3B8), // content-muted lighter
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(LucideIcons.layoutDashboard, size: 20)),
                label: 'INICIO'),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(LucideIcons.receipt, size: 20)),
                label: 'FACTURAS'),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(LucideIcons.user, size: 20)),
                label: 'PERFIL'),
          ],
        ),
      ),
    );
  }
}
