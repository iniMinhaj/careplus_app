import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/medicine.dart';
import '../repository/medicine_repository.dart';

class AddMedicineUsecase implements UseCase<Medicine, AddMedicineParams> {
  final MedicineRepository _repository;

  AddMedicineUsecase({required MedicineRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, Medicine>> call(AddMedicineParams params) async {
    return await _repository.addMedicine(
      name: params.name,
      dosage: params.dosage,
      frequency: params.frequency,
      reminderTimes: params.reminderTimes,
      instructions: params.instructions,
    );
  }
}

class AddMedicineParams extends Equatable {
  final String name;
  final String dosage;
  final String frequency;
  final List<String> reminderTimes;
  final String instructions;

  const AddMedicineParams({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.instructions,
  });

  @override
  List<Object?> get props =>
      [name, dosage, frequency, reminderTimes, instructions];
}
