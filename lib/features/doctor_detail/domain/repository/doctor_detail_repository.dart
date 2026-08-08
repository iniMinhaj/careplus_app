import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entity/doctor_detail.dart';

abstract interface class DoctorDetailRepository {
  Future<Either<Failure, DoctorDetail>> getDoctorById(String id);
}
