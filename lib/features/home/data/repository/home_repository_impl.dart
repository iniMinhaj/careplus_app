import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/doctor.dart';
import '../../domain/entity/specialization.dart';
import '../../domain/repository/home_repository.dart';
import '../datasources/remote/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _homeRemoteDataSource;

  HomeRepositoryImpl({required HomeRemoteDataSource homeRemoteDataSource})
      : _homeRemoteDataSource = homeRemoteDataSource;

  @override
  Future<Either<Failure, List<Specialization>>> getSpecializations() async {
    try {
      final models = await _homeRemoteDataSource.getSpecializations();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Doctor>>> getDoctors({
    String query = '',
    String? specializationId,
    double? minRating,
    bool? availableOnly,
    int? maxFee,
  }) async {
    try {
      final models = await _homeRemoteDataSource.getDoctors(
        query: query,
        specializationId: specializationId,
        minRating: minRating,
        availableOnly: availableOnly,
        maxFee: maxFee,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
