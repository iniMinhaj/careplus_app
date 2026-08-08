import 'package:equatable/equatable.dart';

import '../../domain/entity/appointment.dart';

enum BookingStatus { confirming, submitting, success, failure }

/// Flat platform fee added on top of the doctor's consultation fee — mirrors
/// the legacy MVP screens' hardcoded "+ ৳20".
const int platformFeeBdt = 20;

class BookingState extends Equatable {
  final BookingStatus status;
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String specializationName;
  final int consultationFee;
  final String currency;
  final String date;
  final String time;
  final String consultationType;
  final String reasonForVisit;
  final String paymentMethod;
  final Appointment? appointment;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.confirming,
    this.doctorId = '',
    this.doctorName = '',
    this.doctorPhotoUrl = '',
    this.specializationName = '',
    this.consultationFee = 0,
    this.currency = 'BDT',
    this.date = '',
    this.time = '',
    this.consultationType = 'video',
    this.reasonForVisit = '',
    this.paymentMethod = 'bkash',
    this.appointment,
    this.errorMessage,
  });

  int get totalFee => consultationFee + platformFeeBdt;

  BookingState copyWith({
    BookingStatus? status,
    String? doctorId,
    String? doctorName,
    String? doctorPhotoUrl,
    String? specializationName,
    int? consultationFee,
    String? currency,
    String? date,
    String? time,
    String? consultationType,
    String? reasonForVisit,
    String? paymentMethod,
    Appointment? appointment,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorPhotoUrl: doctorPhotoUrl ?? this.doctorPhotoUrl,
      specializationName: specializationName ?? this.specializationName,
      consultationFee: consultationFee ?? this.consultationFee,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      time: time ?? this.time,
      consultationType: consultationType ?? this.consultationType,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      appointment: appointment ?? this.appointment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctorId,
        doctorName,
        doctorPhotoUrl,
        specializationName,
        consultationFee,
        currency,
        date,
        time,
        consultationType,
        reasonForVisit,
        paymentMethod,
        appointment,
        errorMessage,
      ];
}
