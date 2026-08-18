import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.userId,
    required super.equipmentId,
    required super.quantity,
    required super.pickupDate,
    required super.returnDate,
    required super.status,
    required super.reservationCode,
    super.userName,
    super.studentId,
    super.equipmentName,
    super.equipmentCode,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // Extraer datos del equipo si viene como objeto anidado
    String eqId = '';
    String eqName = '';
    String eqCode = '';
    if (json['equipment'] is Map<String, dynamic>) {
      eqId = json['equipment']['id'] ?? '';
      eqName = json['equipment']['name'] ?? '';
      eqCode = json['equipment']['code'] ?? '';
    } else {
      eqId = json['equipment_id'] ?? json['equipmentId'] ?? '';
    }

    return ReservationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      equipmentId: eqId,
      quantity: json['quantity'] ?? 0,
      pickupDate: DateTime.parse(
        json['pickupDate'] ??
            json['pickup_date'] ??
            DateTime.now().toIso8601String(),
      ),
      returnDate: DateTime.parse(
        json['returnDate'] ??
            json['return_date'] ??
            DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'pending',
      reservationCode: json['qrCode'] ?? json['qr_code'] ?? json['reservation_code'] ?? '',
      userName: json['userName'] ?? json['user_name'] ?? '',
      studentId: json['studentId'] ?? json['student_id'] ?? '',
      equipmentName: eqName,
      equipmentCode: eqCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'equipmentId': equipmentId,
      'quantity': quantity,
      'pickupDate': pickupDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'status': status,
      'reservationCode': reservationCode,
      'userName': userName,
      'studentId': studentId,
      'equipmentName': equipmentName,
      'equipmentCode': equipmentCode,
    };
  }
}
