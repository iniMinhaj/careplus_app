import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/specialization.dart';
import '../repository/home_repository.dart';

class GetSpecializationsUsecase
    implements UseCase<List<Specialization>, NoParams> {
  final HomeRepository _repository;

  GetSpecializationsUsecase({required HomeRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<Specialization>>> call(NoParams params) async {
    return await _repository.getSpecializations();
  }
}
