import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/mock_api_client.dart';
import '../storage/local_json_store.dart';
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
import '../../features/profile/domain/usecase/get_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/home/data/datasources/remote/home_remote_datasource.dart';
import '../../features/home/data/repository/home_repository_impl.dart';
import '../../features/home/domain/repository/home_repository.dart';
import '../../features/home/domain/usecase/get_doctors_usecase.dart';
import '../../features/home/domain/usecase/get_specializations_usecase.dart';
import '../../features/home/presentation/bloc/doctor_list/doctor_list_bloc.dart';
import '../../features/home/presentation/bloc/specialization/specialization_bloc.dart';
import '../../features/booking/data/datasources/remote/booking_remote_datasource.dart';
import '../../features/booking/data/repository/booking_repository_impl.dart';
import '../../features/booking/domain/repository/booking_repository.dart';
import '../../features/booking/domain/usecase/book_appointment_usecase.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  _registerCore();
  _registerAuthModule();
  _registerProfileModule();
  _registerHomeModule();
  _registerBookingModule();
}

void _registerCore() {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<LocalJsonStore>(() => FileLocalJsonStore());
  sl.registerLazySingleton<MockApiClient>(() => MockApiClient(store: sl()));
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

void _registerProfileModule() {
  // Usecase — reuses AuthRepository, no dedicated ProfileRepository
  sl.registerLazySingleton(() => GetProfileUsecase(authRepository: sl()));

  // Bloc — screen-scoped, unlike AuthBloc nothing outside the Profile tab needs it
  sl.registerFactory(() => ProfileBloc(getProfileUsecase: sl()));
}

void _registerHomeModule() {
  // Data sources / repository
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(homeRemoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetSpecializationsUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetDoctorsUsecase(repository: sl()));

  // Blocs — screen-scoped, kept alive by MainShell's IndexedStack for the tab's lifetime
  sl.registerFactory(
    () => SpecializationBloc(getSpecializationsUsecase: sl()),
  );
  sl.registerFactory(() => DoctorListBloc(getDoctorsUsecase: sl()));
}

void _registerBookingModule() {
  // Data sources / repository
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(bookingRemoteDataSource: sl()),
  );

  // Usecase
  sl.registerLazySingleton(() => BookAppointmentUsecase(repository: sl()));

  // Bloc — one instance per booking flow, created when a slot is picked
  sl.registerFactory(
    () => BookingBloc(bookAppointmentUsecase: sl()),
  );
}
