import 'package:careplus/core/error/failures.dart';
import 'package:careplus/features/auth/domain/entity/register_result.dart';
import 'package:careplus/features/auth/domain/entity/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, RegisterResult>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<Either<Failure, String>> requestOtp({required String phone});

  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, User>> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String bloodGroup,
    required String address,
  });
}
