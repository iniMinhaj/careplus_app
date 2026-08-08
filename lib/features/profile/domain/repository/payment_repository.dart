import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entity/payment.dart';

abstract interface class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getPayments();
}
