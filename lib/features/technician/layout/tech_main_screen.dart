import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:elapas_app/features/technician/screens/tech_home_tab.dart';
import 'package:elapas_app/features/technician/screens/tech_installations_tab.dart'; // NUEVO
import 'package:elapas_app/features/technician/screens/tech_readings_tab.dart';
import 'package:elapas_app/features/technician/screens/tech_cuts_tab.dart';
import 'package:elapas_app/features/technician/screens/tech_profile_tab.dart';

class TechMainScreen extends StatefulWidget {
  const TechMainScreen({super.key});

  @override
  State<TechMainScreen> createState() => _TechMainScreenState();
}

class _TechMainScreenState extends State<TechMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    TechHomeTab(),
    TechInstallationsTab(), // 🔥 NUEVO: Pestaña de instalaciones
    TechReadingsTab(),
    TechCutsTab(),
    TechProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0F172A),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 9, // Ajustado para que entren 5 tabs
          unselectedFontSize: 9,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(LucideIcons.layoutDashboard, size: 20)),
                label: 'INICIO'),
            BottomNavigationBarItem(
                // 🔥 NUEVO
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(LucideIcons.wrench, size: 20)),
                label: 'INSTALAR'),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(LucideIcons.scanLine, size: 20)),
                label: 'LECTURAS'),
            BottomNavigationBarItem(
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(LucideIcons.scissors, size: 20)),
                label: 'CORTES'),
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
