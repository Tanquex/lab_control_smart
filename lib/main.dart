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
      title: 'LabControl Smart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const EquipmentScreen(),
    );
  }
}
