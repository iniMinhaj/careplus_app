import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/appointments_repository.dart';

class GetAppointmentsUsecase implements UseCase<List<Appointment>, NoParams> {
  final AppointmentsRepository _repository;

  GetAppointmentsUsecase({required AppointmentsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<Appointment>>> call(NoParams params) async {
    return await _repository.getAppointments();
  }
}
