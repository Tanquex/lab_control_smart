import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'features/equipment/presentation/screens/equipment_screen.dart';

void main() {
  runApp(const LabControlApp());
}

class LabControlApp extends StatelessWidget {
  const LabControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabControl Smart TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tvDarkTheme,
      darkTheme: AppTheme.tvDarkTheme,
      themeMode: ThemeMode.dark,
      home: const EquipmentScreen(),
    );
  }
}
