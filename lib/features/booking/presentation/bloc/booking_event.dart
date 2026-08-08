import 'package:equatable/equatable.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once, right after the user picks a date + slot on the doctor
/// detail screen, to seed the flow's state before the confirm screen opens.
class BookingStarted extends BookingEvent {
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String specializationName;
  final int consultationFee;
  final String currency;
  final String date;
  final String time;

  const BookingStarted({
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.specializationName,
    required this.consultationFee,
    required this.currency,
    required this.date,
    required this.time,
  });

  @override
  List<Object?> get props => [
        doctorId,
        doctorName,
        doctorPhotoUrl,
        specializationName,
        consultationFee,
        currency,
        date,
        time,
      ];
}

class ConsultationTypeChanged extends BookingEvent {
  final String consultationType;

  const ConsultationTypeChanged(this.consultationType);

  @override
  List<Object?> get props => [consultationType];
}

class ReasonForVisitChanged extends BookingEvent {
  final String reasonForVisit;

  const ReasonForVisitChanged(this.reasonForVisit);

  @override
  List<Object?> get props => [reasonForVisit];
}

class PaymentMethodChanged extends BookingEvent {
  final String paymentMethod;

  const PaymentMethodChanged(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class PaymentSubmitted extends BookingEvent {
  const PaymentSubmitted();
}
