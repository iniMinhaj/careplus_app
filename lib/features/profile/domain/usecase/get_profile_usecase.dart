import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/entity/user.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:fpdart/fpdart.dart';

class GetProfileUsecase implements UseCase<User, NoParams> {
  final AuthRepository _authRepository;

  GetProfileUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await _authRepository.getCurrentUser();
  }
}
