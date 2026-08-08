import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/appointments_repository.dart';

class CancelAppointmentUsecase
    implements UseCase<Appointment, CancelAppointmentParams> {
  final AppointmentsRepository _repository;

  CancelAppointmentUsecase({required AppointmentsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, Appointment>> call(
    CancelAppointmentParams params,
  ) async {
    return await _repository.cancelAppointment(params.appointmentId);
  }
}

class CancelAppointmentParams extends Equatable {
  final String appointmentId;

  const CancelAppointmentParams({required this.appointmentId});

  @override
  List<Object?> get props => [appointmentId];
}
