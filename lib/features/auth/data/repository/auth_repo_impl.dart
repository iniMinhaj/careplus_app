import 'package:careplus/core/error/error_handler.dart';
import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/storage/token_manager.dart';
import 'package:careplus/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:careplus/features/auth/domain/entity/register_result.dart';
import 'package:careplus/features/auth/domain/entity/user.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final TokenManager _tokenManager;

  AuthRepositoryImpl(
      {required AuthRemoteDataSource authRemoteDataSource,
      required TokenManager tokenManager})
      : _tokenManager = tokenManager,
        _authRemoteDataSource = authRemoteDataSource;

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userId = await _tokenManager.getUserId();
      final userModel =
          await _authRemoteDataSource.getCurrentUser(userId: userId);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final hasToken = await _tokenManager.hasStoredToken();
      return Right(hasToken);
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login(
      {required String email, required String password}) async {
    try {
      final authResponse =
          await _authRemoteDataSource.login(email: email, password: password);
      await _tokenManager.saveTokens(accessToken: authResponse.accessToken);
      final user = authResponse.user.toEntity();
      await _tokenManager.saveUserId(user.id);
      return Right(user);
    } on InvalidCredentialsException {
      return const Left(AuthFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _tokenManager.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RegisterResult>> register(
      {required String name,
      required String email,
      required String password,
      required String phone}) async {
    try {
      final registerResponse = await _authRemoteDataSource.register(
          name: name, email: email, phone: phone, password: password);
      return Right(registerResponse.toEntity());
    } on EmailAlreadyInUseException {
      return const Left(
          ClientFailure(message: 'An account with this email already exists'));
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestOtp({required String phone}) async {
    try {
      final otpReference = await _authRemoteDataSource.requestOtp(phone: phone);
      return Right(otpReference);
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(
      {required String phone, required String otp}) async {
    try {
      final verified =
          await _authRemoteDataSource.verifyOtp(phone: phone, otp: otp);
      return Right(verified);
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
