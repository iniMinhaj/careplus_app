import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repository/appointments_repository.dart';
import '../datasources/remote/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource _appointmentsRemoteDataSource;

  AppointmentsRepositoryImpl({
    required AppointmentsRemoteDataSource appointmentsRemoteDataSource,
  }) : _appointmentsRemoteDataSource = appointmentsRemoteDataSource;

  @override
  Future<Either<Failure, List<Appointment>>> getAppointments() async {
    try {
      final models = await _appointmentsRemoteDataSource.getAppointments();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Appointment>> cancelAppointment(String id) async {
    try {
      final model = await _appointmentsRemoteDataSource.cancelAppointment(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
