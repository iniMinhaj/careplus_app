import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/health_record.dart';
import '../repository/health_records_repository.dart';

class GetHealthRecordsUsecase implements UseCase<List<HealthRecord>, NoParams> {
  final HealthRecordsRepository _repository;

  GetHealthRecordsUsecase({required HealthRecordsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<HealthRecord>>> call(NoParams params) async {
    return await _repository.getRecords();
  }
}
