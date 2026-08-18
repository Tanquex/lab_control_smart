class Reservation {
  final String id;
  final String userId;
  final String equipmentId;
  final int quantity;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String status; // 'pending', 'active', 'completed', 'cancelled'
  final String reservationCode;

  // Campos adicionales devueltos por la API para visualización en el Dashboard de TV
  final String? userName;
  final String? studentId;
  final String? equipmentName;
  final String? equipmentCode;

  const Reservation({
    required this.id,
    required this.userId,
    required this.equipmentId,
    required this.quantity,
    required this.pickupDate,
    required this.returnDate,
    required this.status,
    required this.reservationCode,
    this.userName,
    this.studentId,
    this.equipmentName,
    this.equipmentCode,
  });
}
