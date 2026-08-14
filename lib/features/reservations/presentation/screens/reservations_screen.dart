import 'package:flutter/material.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas y Devoluciones'),
      ),
      body: const Center(
        child: Text('Cola de Préstamos / Devoluciones'),
      ),
    );
  }
}
