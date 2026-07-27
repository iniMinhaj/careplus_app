import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class RequestOtpUsecase implements UseCase<String, RequestOtpParams> {
  final AuthRepository _authRepository;

  RequestOtpUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;
  @override
  Future<Either<Failure, String>> call(params) async {
    return await _authRepository.requestOtp(phone: params.phone);
  }
}

class RequestOtpParams extends Equatable {
  final String phone;

  const RequestOtpParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}
