import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entity/health_record.dart';

abstract interface class HealthRecordsRepository {
  Future<Either<Failure, List<HealthRecord>>> getRecords();

  Future<Either<Failure, HealthRecord>> uploadRecord({
    required String title,
    required String type,
    required String filePath,
    required String fileType,
    String? notes,
  });
}
