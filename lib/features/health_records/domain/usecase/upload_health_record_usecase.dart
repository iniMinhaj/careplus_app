import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/health_record.dart';
import '../repository/health_records_repository.dart';

class UploadHealthRecordUsecase
    implements UseCase<HealthRecord, UploadHealthRecordParams> {
  final HealthRecordsRepository _repository;

  UploadHealthRecordUsecase({required HealthRecordsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, HealthRecord>> call(
    UploadHealthRecordParams params,
  ) async {
    return await _repository.uploadRecord(
      title: params.title,
      type: params.type,
      filePath: params.filePath,
      fileType: params.fileType,
      notes: params.notes,
    );
  }
}

class UploadHealthRecordParams extends Equatable {
  final String title;
  final String type;
  final String filePath;
  final String fileType;
  final String? notes;

  const UploadHealthRecordParams({
    required this.title,
    required this.type,
    required this.filePath,
    required this.fileType,
    this.notes,
  });

  @override
  List<Object?> get props => [title, type, filePath, fileType, notes];
}
