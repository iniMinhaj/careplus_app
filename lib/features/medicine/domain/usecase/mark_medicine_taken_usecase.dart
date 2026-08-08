import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/medicine_repository.dart';

class MarkMedicineTakenUsecase
    implements UseCase<void, MarkMedicineTakenParams> {
  final MedicineRepository _repository;

  MarkMedicineTakenUsecase({required MedicineRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(MarkMedicineTakenParams params) async {
    return await _repository.markTaken(
      medicineId: params.medicineId,
      time: params.time,
    );
  }
}

class MarkMedicineTakenParams extends Equatable {
  final String medicineId;
  final String time;

  const MarkMedicineTakenParams({
    required this.medicineId,
    required this.time,
  });

  @override
  List<Object?> get props => [medicineId, time];
}
