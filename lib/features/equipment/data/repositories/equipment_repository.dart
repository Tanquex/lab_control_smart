import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../config/constants/api_routes.dart';
import '../../../../config/constants/environment.dart';
import '../models/equipment_model.dart';

class EquipmentRepository {
  final http.Client client;

  EquipmentRepository({http.Client? client})
      : client = client ?? http.Client();

  /// Obtiene la lista de equipos en tiempo real desde el Backend de LabControl (http://localhost:8080/api/equipment).
  /// Si el servidor backend no está corriendo localmente, retorna datos de respaldo (fallback).
  Future<List<EquipmentModel>> getEquipmentList() async {
    final String url = '${Environment.baseUrl}${ApiRoutes.equipment}';

    try {
      if (kDebugMode) {
        print('📡 [LabControl API] Solicitando equipos a: $url');
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
          } else if (body.containsKey('equipment') && body['equipment'] is List) {
            jsonList = body['equipment'];
          }
        }

        final items = jsonList
            .map((item) => EquipmentModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (kDebugMode) {
          print('✅ [LabControl API] Petición exitosa: ${items.length} equipos cargados desde el backend.');
        }

        return items;
      } else {
        if (kDebugMode) {
          print('⚠️ [LabControl API] Respuesta del servidor con estado: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [LabControl API] Backend inaccesible ($e). Usando datos de prueba locales de respaldo.');
      }
    }

    // Fallback de datos locales en caso de que el backend no esté encendido
    return _getFallbackEquipmentList();
  }

  /// Datos de respaldo locales cuando el servidor no responde
  List<EquipmentModel> _getFallbackEquipmentList() {
    return const [
      EquipmentModel(
        id: '101',
        name: 'Kit Arduino Uno R3',
        categoryId: 'Electrónica',
        code: 'EQ-001',
        location: 'Laboratorio 3 - Mesa A',
        totalUnits: 15,
        availableUnits: 12,
        imageUrl: '',
      ),
      EquipmentModel(
        id: '102',
        name: 'Osciloscopio Digital 100MHz',
        categoryId: 'Electrónica',
        code: 'EQ-002',
        location: 'Laboratorio 3 - Estante 2',
        totalUnits: 6,
        availableUnits: 2,
        imageUrl: '',
      ),
      EquipmentModel(
        id: '103',
        name: 'Multímetro Digital TRMS',
        categoryId: 'Electrónica',
        code: 'EQ-003',
        location: 'Laboratorio 1 - Gabinete 4',
        totalUnits: 20,
        availableUnits: 18,
        imageUrl: '',
      ),
      EquipmentModel(
        id: '104',
        name: 'Raspberry Pi 4 Model B (4GB)',
        categoryId: 'Cómputo',
        code: 'EQ-004',
        location: 'Laboratorio 2 - Rack B',
        totalUnits: 10,
        availableUnits: 0,
        imageUrl: '',
      ),
      EquipmentModel(
        id: '105',
        name: 'Fuente de Poder Regulable 30V 5A',
        categoryId: 'Electrónica',
        code: 'EQ-005',
        location: 'Laboratorio 3 - Mesa B',
        totalUnits: 8,
        availableUnits: 5,
        imageUrl: '',
      ),
      EquipmentModel(
        id: '106',
        name: 'Generador de Funciones 25MHz',
        categoryId: 'Electrónica',
        code: 'EQ-006',
        location: 'Laboratorio 3 - Estante 1',
        totalUnits: 5,
        availableUnits: 1,
        imageUrl: '',
      ),
    ];
  }
}
