import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/payment.dart';
import '../../domain/repository/payment_repository.dart';
import '../datasources/remote/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _paymentRemoteDataSource;

  PaymentRepositoryImpl({
    required PaymentRemoteDataSource paymentRemoteDataSource,
  }) : _paymentRemoteDataSource = paymentRemoteDataSource;

  @override
  Future<Either<Failure, List<Payment>>> getPayments() async {
    try {
      final models = await _paymentRemoteDataSource.getPayments();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
