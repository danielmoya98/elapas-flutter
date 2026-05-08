import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Importaremos las pestañas (las creamos en el siguiente paso)
import '../screens/tech_home_tab.dart';
import '../screens/tech_readings_tab.dart';
import '../screens/tech_cuts_tab.dart';
import '../screens/tech_profile_tab.dart';

class TechMainScreen extends StatefulWidget {
  const TechMainScreen({super.key});

  @override
  State<TechMainScreen> createState() => _TechMainScreenState();
}

class _TechMainScreenState extends State<TechMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    TechHomeTab(),
    TechReadingsTab(),
    TechCutsTab(),
    TechProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 10,
        indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(LucideIcons.layoutDashboard),
            selectedIcon: Icon(LucideIcons.layoutDashboard,
                color: Theme.of(context).primaryColor),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.scanLine),
            selectedIcon: Icon(LucideIcons.scanLine,
                color: Theme.of(context).primaryColor),
            label: 'Lecturas',
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.scissors),
            selectedIcon: Icon(LucideIcons.scissors,
                color: Theme.of(context).primaryColor),
            label: 'Cortes',
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.user),
            selectedIcon:
                Icon(LucideIcons.user, color: Theme.of(context).primaryColor),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
