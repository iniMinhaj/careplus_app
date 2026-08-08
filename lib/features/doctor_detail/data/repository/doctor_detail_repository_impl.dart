import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/doctor_detail.dart';
import '../../domain/repository/doctor_detail_repository.dart';
import '../datasources/remote/doctor_detail_remote_datasource.dart';

class DoctorDetailRepositoryImpl implements DoctorDetailRepository {
  final DoctorDetailRemoteDataSource _doctorDetailRemoteDataSource;

  DoctorDetailRepositoryImpl({
    required DoctorDetailRemoteDataSource doctorDetailRemoteDataSource,
  }) : _doctorDetailRemoteDataSource = doctorDetailRemoteDataSource;

  @override
  Future<Either<Failure, DoctorDetail>> getDoctorById(String id) async {
    try {
      final model = await _doctorDetailRemoteDataSource.getDoctorById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
