import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../entity/register_result.dart';

class RegisterUsecase implements UseCase<RegisterResult, RegisterParams> {
  final AuthRepository _authRepository;

  RegisterUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;
  @override
  Future<Either<Failure, RegisterResult>> call(RegisterParams params) async {
    return await _authRepository.register(
        name: params.name,
        email: params.email,
        password: params.password,
        phone: params.phone);
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterParams(
      {required this.name,
      required this.email,
      required this.phone,
      required this.password});

  @override
  List<Object?> get props => [name, email, phone, password];
}
