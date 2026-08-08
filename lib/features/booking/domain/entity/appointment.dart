import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String specializationName;
  final String date;
  final String time;
  final String status;
  final int fee;
  final String currency;
  final String paymentStatus;
  final String paymentMethod;
  final String consultationType;
  final String reasonForVisit;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.specializationName,
    required this.date,
    required this.time,
    required this.status,
    required this.fee,
    required this.currency,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.consultationType,
    required this.reasonForVisit,
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        doctorName,
        doctorPhotoUrl,
        specializationName,
        date,
        time,
        status,
        fee,
        currency,
        paymentStatus,
        paymentMethod,
        consultationType,
        reasonForVisit,
      ];
}
