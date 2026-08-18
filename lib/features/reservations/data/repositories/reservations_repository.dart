import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../config/constants/api_routes.dart';
import '../../../../config/constants/environment.dart';
import '../models/reservation_model.dart';

class ReservationsRepository {
  final http.Client client;

  ReservationsRepository({http.Client? client})
      : client = client ?? http.Client();

  /// Obtiene la lista de reservas en tiempo real desde el Backend de LabControl
  /// Si el servidor backend no está corriendo localmente, retorna datos de respaldo (fallback).
  Future<List<ReservationModel>> getReservationsList() async {
    final String url = '${Environment.baseUrl}${ApiRoutes.reservations}';

    try {
      if (kDebugMode) {
        print('📡 [LabControl API] Solicitando reservas a: $url');
      }

      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);

        List<dynamic> jsonList = [];
        if (body is List) {
          jsonList = body;
        } else if (body is Map<String, dynamic>) {
          if (body.containsKey('data') && body['data'] is List) {
            jsonList = body['data'];
          } else if (body.containsKey('reservations') && body['reservations'] is List) {
            jsonList = body['reservations'];
          }
        }

        final items = jsonList
            .map((item) => ReservationModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (kDebugMode) {
          print('✅ [LabControl API] Petición exitosa: ${items.length} reservas cargadas desde el backend.');
        }

        return items;
      } else {
        if (kDebugMode) {
          print('⚠️ [LabControl API] Respuesta del servidor con estado: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [LabControl API] Backend inaccesible ($e). Usando reservas locales de respaldo.');
      }
    }

    // Fallback de datos locales en caso de que el backend no esté encendido
    return _getFallbackReservationsList();
  }

  /// Datos de respaldo locales cuando el servidor no responde
  List<ReservationModel> _getFallbackReservationsList() {
    final now = DateTime.now();
    return [
      ReservationModel(
        id: 'r1',
        userId: 'u1',
        equipmentId: '103', // Cable USB-C
        quantity: 1,
        pickupDate: now.subtract(const Duration(hours: 2)),
        returnDate: now.add(const Duration(hours: 2)),
        status: 'active',
        reservationCode: 'QR-RES-001',
        userName: 'Ana García',
        studentId: '1300011',
        equipmentName: 'Cable USB-C',
        equipmentCode: 'EQ-003',
      ),
      ReservationModel(
        id: 'r2',
        userId: 'u2',
        equipmentId: '101', // Kit Arduino
        quantity: 1,
        pickupDate: now.subtract(const Duration(hours: 3)),
        returnDate: now.subtract(const Duration(minutes: 30)),
        status: 'completed',
        reservationCode: 'QR-RES-002',
        userName: 'Diego López',
        studentId: '1300022',
        equipmentName: 'Kit Arduino Uno R3',
        equipmentCode: 'EQ-001',
      ),
      ReservationModel(
        id: 'r3',
        userId: 'u3',
        equipmentId: '102', // Osciloscopio
        quantity: 1,
        pickupDate: now.subtract(const Duration(hours: 1)),
        returnDate: now.add(const Duration(minutes: 30)),
        status: 'active',
        reservationCode: 'QR-RES-003',
        userName: 'Sofía Ramírez',
        studentId: '1300033',
        equipmentName: 'Osciloscopio Digital 100MHz',
        equipmentCode: 'EQ-002',
      ),
      ReservationModel(
        id: 'r4',
        userId: 'u4',
        equipmentId: '104', // Laptop HP
        quantity: 1,
        pickupDate: now.add(const Duration(hours: 1)),
        returnDate: now.add(const Duration(hours: 3)),
        status: 'pending',
        reservationCode: 'QR-RES-004',
        userName: 'Carlos Mora',
        studentId: '1300040',
        equipmentName: 'Laptop HP',
        equipmentCode: 'EQ-004',
      ),
      ReservationModel(
        id: 'r5',
        userId: 'u5',
        equipmentId: '103', // Multímetro (Vencido)
        quantity: 1,
        pickupDate: now.subtract(const Duration(hours: 4)),
        returnDate: now.subtract(const Duration(minutes: 45)),
        status: 'active',
        reservationCode: 'QR-RES-005',
        userName: 'Hames Manne',
        studentId: '1300051',
        equipmentName: 'Multímetro Digital TRMS',
        equipmentCode: 'EQ-003',
      ),
      ReservationModel(
        id: 'r6',
        userId: 'u6',
        equipmentId: '104', // Raspberry Pi 4 (Vencido)
        quantity: 1,
        pickupDate: now.subtract(const Duration(hours: 3)),
        returnDate: now.subtract(const Duration(minutes: 30)),
        status: 'active',
        reservationCode: 'QR-RES-006',
        userName: 'Nono Hame',
        studentId: '1300062',
        equipmentName: 'Raspberry Pi 4 Model B (4GB)',
        equipmentCode: 'EQ-004',
      ),
    ];
  }
}
