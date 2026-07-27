import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entity/user.dart';

class LoginUsecase implements UseCase<User, LoginParams> {
  final AuthRepository _repository;

  LoginUsecase({required AuthRepository repository}) : _repository = repository;
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await _repository.login(
        email: params.email, password: params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
