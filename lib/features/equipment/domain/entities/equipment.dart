class Equipment {
  final String id;
  final String name;
  final String categoryId;
  final String code;
  final String location;
  final int totalUnits;
  final int availableUnits;
  final String imageUrl;

  const Equipment({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.code,
    required this.location,
    required this.totalUnits,
    required this.availableUnits,
    required this.imageUrl,
  });
}
