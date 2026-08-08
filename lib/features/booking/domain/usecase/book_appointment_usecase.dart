import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/appointment.dart';
import '../repository/booking_repository.dart';

class BookAppointmentUsecase
    implements UseCase<Appointment, BookAppointmentParams> {
  final BookingRepository _repository;

  BookAppointmentUsecase({required BookingRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, Appointment>> call(
    BookAppointmentParams params,
  ) async {
    return await _repository.bookAppointment(
      doctorId: params.doctorId,
      doctorName: params.doctorName,
      doctorPhotoUrl: params.doctorPhotoUrl,
      specializationName: params.specializationName,
      date: params.date,
      time: params.time,
      fee: params.fee,
      currency: params.currency,
      consultationType: params.consultationType,
      reasonForVisit: params.reasonForVisit,
      paymentMethod: params.paymentMethod,
    );
  }
}

class BookAppointmentParams extends Equatable {
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String specializationName;
  final String date;
  final String time;
  final int fee;
  final String currency;
  final String consultationType;
  final String reasonForVisit;
  final String paymentMethod;

  const BookAppointmentParams({
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.specializationName,
    required this.date,
    required this.time,
    required this.fee,
    required this.currency,
    required this.consultationType,
    required this.reasonForVisit,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        doctorId,
        doctorName,
        doctorPhotoUrl,
        specializationName,
        date,
        time,
        fee,
        currency,
        consultationType,
        reasonForVisit,
        paymentMethod,
      ];
}
