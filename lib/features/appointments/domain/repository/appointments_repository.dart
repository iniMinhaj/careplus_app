import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

abstract interface class AppointmentsRepository {
  Future<Either<Failure, List<Appointment>>> getAppointments();
  Future<Either<Failure, Appointment>> cancelAppointment(String id);
}
