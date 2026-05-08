import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Light (Igual a tu React)
  static const Color lightBackground = Color(0xFFF8FAFC); // canvas
  static const Color lightSurface = Color(0xFFFFFFFF); // surface
  static const Color lightTextMain = Color(0xFF0F172A); // content-main
  static const Color lightTextMuted = Color(0xFF64748B); // content-muted
  static const Color lightBorder = Color(0xFFE2E8F0); // border-soft
  static const Color primary = Color(0xFF0284C7); // sky-600 (Acento principal)

  // Paleta Dark
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkTextMain = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: lightSurface,
        onSurface: lightTextMain,
      ),
      // Tipografía Inter (Estilo Suizo: geométrica, legible, sin serifas)
      textTheme: const TextTheme().apply(
        bodyColor: lightTextMain,
        displayColor: lightTextMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextMain,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: lightTextMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              lightTextMain, // Botones oscuros por defecto (estilo Vercel/React)
          foregroundColor: lightSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Aquí replicarías lo mismo pero con los colores dark
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: darkSurface,
        onSurface: darkTextMain,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: darkTextMain,
        displayColor: darkTextMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextMain,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primary, width: 2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTextMain,
          foregroundColor: darkSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
