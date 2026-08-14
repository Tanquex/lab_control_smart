import '../models/equipment_model.dart';

class EquipmentRepository {
  /// Retorna lista de equipos de laboratorio (mock inicial para pruebas de TV y UI)
  Future<List<EquipmentModel>> getEquipmentList() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));

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
        availableUnits: 0, // Agotado para probar badge de agotado
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
        availableUnits: 1, // Stock bajo
        imageUrl: '',
      ),
      EquipmentModel(
        id: '107',
        name: 'Cámara Térmica FLIR',
        categoryId: 'Medición',
        code: 'EQ-007',
        location: 'Laboratorio Especializado',
        totalUnits: 3,
        availableUnits: 3,
        imageUrl: '',
      ),
      EquipmentModel(
        id: '108',
        name: 'Analizador de Lógica USB 8CH',
        categoryId: 'Redes',
        code: 'EQ-008',
        location: 'Laboratorio 2 - Estante 3',
        totalUnits: 12,
        availableUnits: 9,
        imageUrl: '',
      ),
    ];
  }
}
