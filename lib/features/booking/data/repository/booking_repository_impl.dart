import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/appointment.dart';
import '../../domain/repository/booking_repository.dart';
import '../datasources/remote/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _bookingRemoteDataSource;

  BookingRepositoryImpl({
    required BookingRemoteDataSource bookingRemoteDataSource,
  }) : _bookingRemoteDataSource = bookingRemoteDataSource;

  @override
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
  }) async {
    try {
      final model = await _bookingRemoteDataSource.bookAppointment(
        doctorId: doctorId,
        doctorName: doctorName,
        doctorPhotoUrl: doctorPhotoUrl,
        specializationName: specializationName,
        date: date,
        time: time,
        fee: fee,
        currency: currency,
        consultationType: consultationType,
        reasonForVisit: reasonForVisit,
        paymentMethod: paymentMethod,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
