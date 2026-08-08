import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entity/doctor.dart';
import '../entity/specialization.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<Specialization>>> getSpecializations();

  Future<Either<Failure, List<Doctor>>> getDoctors({
    String query = '',
    String? specializationId,
    double? minRating,
    bool? availableOnly,
    int? maxFee,
  });
}
