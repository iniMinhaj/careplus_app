import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entity/medicine.dart';

abstract interface class MedicineRepository {
  Future<Either<Failure, List<Medicine>>> getMedicines();

  Future<Either<Failure, Medicine>> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    required String instructions,
  });

  Future<Either<Failure, void>> markTaken({
    required String medicineId,
    required String time,
  });
}
