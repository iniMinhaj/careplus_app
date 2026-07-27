import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class VerifyOtpUsecase implements UseCase<bool, VerifyOtpParams> {
  final AuthRepository _authRepository;

  VerifyOtpUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;
  @override
  Future<Either<Failure, bool>> call(VerifyOtpParams params) async {
    return await _authRepository.verifyOtp(
        phone: params.phone, otp: params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otp;

  const VerifyOtpParams({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}
