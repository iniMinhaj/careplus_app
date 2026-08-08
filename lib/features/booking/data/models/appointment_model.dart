import '../../domain/entity/appointment.dart';

class AppointmentModel {
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

  AppointmentModel({
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json['id'],
        doctorId: json['doctorId'] ?? '',
        doctorName: json['doctorName'] ?? '',
        doctorPhotoUrl: json['doctorPhotoUrl'] ?? '',
        specializationName: json['specializationName'] ?? '',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        status: json['status'] ?? 'upcoming',
        fee: json['fee'] ?? 0,
        currency: json['currency'] ?? 'BDT',
        paymentStatus: json['paymentStatus'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        consultationType: json['consultationType'] ?? 'in-person',
        reasonForVisit: json['reasonForVisit'] ?? '',
      );

  Appointment toEntity() => Appointment(
        id: id,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorPhotoUrl: doctorPhotoUrl,
        specializationName: specializationName,
        date: date,
        time: time,
        status: status,
        fee: fee,
        currency: currency,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        consultationType: consultationType,
        reasonForVisit: reasonForVisit,
      );
}
