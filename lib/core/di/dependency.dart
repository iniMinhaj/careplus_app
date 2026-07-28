import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/mock_api_client.dart';
import '../storage/token_manager.dart';
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repository/auth_repo_impl.dart';
import '../../features/auth/domain/repository/auth_repo.dart';
import '../../features/auth/domain/usecase/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/logout_usecase.dart';
import '../../features/auth/domain/usecase/register_usecase.dart';
import '../../features/auth/domain/usecase/request_otp_usecase.dart';
import '../../features/auth/domain/usecase/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  _registerCore();
  _registerAuthModule();
}

void _registerCore() {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<MockApiClient>(() => MockApiClient());
}

void _registerAuthModule() {
  // Storage / data sources
  sl.registerLazySingleton<TokenManager>(() => SecureTokenManager(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourcImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      tokenManager: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => LoginUsecase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => RequestOtpUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => VerifyOtpUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => LogoutUsecase(authRepository: sl()));
  sl.registerLazySingleton(
    () => CheckAuthStatusUsecase(authRepository: sl()),
  );

  // Bloc — app-wide singleton so auth state survives across the nav stack
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUsecase: sl(),
      registerUsecase: sl(),
      requestOtpUsecase: sl(),
      verifyOtpUsecase: sl(),
      logoutUsecase: sl(),
      checkAuthStatusUsecase: sl(),
    ),
  );
}
