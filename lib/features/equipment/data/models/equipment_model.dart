import '../../domain/entities/equipment.dart';

class EquipmentModel extends Equipment {
  const EquipmentModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.code,
    required super.location,
    required super.totalUnits,
    required super.availableUnits,
    required super.imageUrl,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      code: json['code'] ?? '',
      location: json['location'] ?? '',
      totalUnits: json['total_units'] ?? json['totalUnits'] ?? 0,
      availableUnits: json['available_units'] ?? json['availableUnits'] ?? 0,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'code': code,
      'location': location,
      'total_units': totalUnits,
      'available_units': availableUnits,
      'image_url': imageUrl,
    };
  }
}
