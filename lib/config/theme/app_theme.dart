import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Colores Oficial de LabControl (Material 3 Universitario)
  static const Color primary = Color(0xFF16A34A);        // Verde Esmeralda
  static const Color primaryDark = Color(0xFF15803D);    // Verde Oscuro
  static const Color background = Color(0xFFF7F8FA);     // Fondo Claro
  static const Color cardSurface = Color(0xFFFFFFFF);    // Superficie Tarjetas
  static const Color textPrimary = Color(0xFF111827);    // Texto Principal
  static const Color textSecondary = Color(0xFF6B7280);  // Texto Secundario

  // Estados de Disponibilidad
  static const Color statusAvailable = Color(0xFF22C55E);  // Stock > 2
  static const Color statusWarning = Color(0xFFF59E0B);    // Stock <= 2
  static const Color statusUnavailable = Color(0xFFEF4444);// Stock == 0

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: cardSurface,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: textSecondary,
        ),
      ),
    );
  }

  static ThemeData get tvDarkTheme => lightTheme;
}
