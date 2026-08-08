import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entity/appointment.dart';

abstract interface class BookingRepository {
  Future<Either<Failure, Appointment>> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorPhotoUrl,
    required String specializationName,
    required String date,
    required String time,
    required int fee,
    required String currency,
    required String consultationType,
    required String reasonForVisit,
    required String paymentMethod,
  });
}
