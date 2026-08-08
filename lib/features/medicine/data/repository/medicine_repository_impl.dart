import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/medicine.dart';
import '../../domain/repository/medicine_repository.dart';
import '../datasources/remote/medicine_remote_datasource.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource _medicineRemoteDataSource;

  MedicineRepositoryImpl({
    required MedicineRemoteDataSource medicineRemoteDataSource,
  }) : _medicineRemoteDataSource = medicineRemoteDataSource;

  @override
  Future<Either<Failure, List<Medicine>>> getMedicines() async {
    try {
      final models = await _medicineRemoteDataSource.getMedicines();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Medicine>> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    required String instructions,
  }) async {
    try {
      final model = await _medicineRemoteDataSource.addMedicine(
        name: name,
        dosage: dosage,
        frequency: frequency,
        reminderTimes: reminderTimes,
        instructions: instructions,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markTaken({
    required String medicineId,
    required String time,
  }) async {
    try {
      await _medicineRemoteDataSource.markTaken(
        medicineId: medicineId,
        time: time,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
