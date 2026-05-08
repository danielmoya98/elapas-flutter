import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/customer_home_tab.dart';
import '../screens/customer_invoices_tab.dart';
import '../screens/customer_profile_tab.dart';

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
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(LucideIcons.home, size: 20), label: 'INICIO'),
            BottomNavigationBarItem(
                icon: Icon(LucideIcons.fileText, size: 20), label: 'FACTURAS'),
            BottomNavigationBarItem(
                icon: Icon(LucideIcons.user, size: 20), label: 'PERFIL'),
          ],
        ),
      ),
    );
  }
}
