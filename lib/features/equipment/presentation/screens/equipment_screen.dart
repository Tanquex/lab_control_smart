import 'package:flutter/material.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos de Laboratorio'),
      ),
      body: const Center(
        child: Text('Lista / Stock de Equipos'),
      ),
    );
  }
}
