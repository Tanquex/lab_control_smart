class Reservation {
  final String id;
  final String userId;
  final String equipmentId;
  final int quantity;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String status; // 'pending', 'active', 'completed', 'cancelled'
  final String reservationCode;

  const Reservation({
    required this.id,
    required this.userId,
    required this.equipmentId,
    required this.quantity,
    required this.pickupDate,
    required this.returnDate,
    required this.status,
    required this.reservationCode,
  });
}
