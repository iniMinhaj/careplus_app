import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:fpdart/fpdart.dart';

class LogoutUsecase implements UseCase<void, NoParams> {
  final AuthRepository _authRepository;

  LogoutUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await _authRepository.logout();
  }
}
