import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/medicine.dart';
import '../repository/medicine_repository.dart';

class GetMedicinesUsecase implements UseCase<List<Medicine>, NoParams> {
  final MedicineRepository _repository;

  GetMedicinesUsecase({required MedicineRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<Medicine>>> call(NoParams params) async {
    return await _repository.getMedicines();
  }
}
