import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:fpdart/fpdart.dart';

class CheckAuthStatusUsecase implements UseCase<bool, NoParams> {
  final AuthRepository _authRepository;

  CheckAuthStatusUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await _authRepository.isLoggedIn();
  }
}
