import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/payment.dart';
import '../repository/payment_repository.dart';

class GetPaymentsUsecase implements UseCase<List<Payment>, NoParams> {
  final PaymentRepository _repository;

  GetPaymentsUsecase({required PaymentRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<Payment>>> call(NoParams params) async {
    return await _repository.getPayments();
  }
}
