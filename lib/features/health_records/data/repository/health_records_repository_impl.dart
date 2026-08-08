import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/health_record.dart';
import '../../domain/repository/health_records_repository.dart';
import '../datasources/remote/health_records_remote_datasource.dart';

class HealthRecordsRepositoryImpl implements HealthRecordsRepository {
  final HealthRecordsRemoteDataSource _healthRecordsRemoteDataSource;

  HealthRecordsRepositoryImpl({
    required HealthRecordsRemoteDataSource healthRecordsRemoteDataSource,
  }) : _healthRecordsRemoteDataSource = healthRecordsRemoteDataSource;

  @override
  Future<Either<Failure, List<HealthRecord>>> getRecords() async {
    try {
      final models = await _healthRecordsRemoteDataSource.getRecords();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthRecord>> uploadRecord({
    required String title,
    required String type,
    required String filePath,
    required String fileType,
    String? notes,
  }) async {
    try {
      final model = await _healthRecordsRemoteDataSource.uploadRecord(
        title: title,
        type: type,
        filePath: filePath,
        fileType: fileType,
        notes: notes,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
