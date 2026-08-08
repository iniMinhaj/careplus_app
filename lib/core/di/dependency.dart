import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/mock_api_client.dart';
import '../notifications/notification_service.dart';
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
import '../../features/profile/data/datasources/remote/payment_remote_datasource.dart';
import '../../features/profile/data/repository/payment_repository_impl.dart';
import '../../features/profile/domain/repository/payment_repository.dart';
import '../../features/profile/domain/usecase/get_payments_usecase.dart';
import '../../features/profile/domain/usecase/get_profile_usecase.dart';
import '../../features/profile/domain/usecase/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/payment_history_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/home/data/datasources/remote/home_remote_datasource.dart';
import '../../features/home/data/repository/home_repository_impl.dart';
import '../../features/home/domain/repository/home_repository.dart';
import '../../features/home/domain/usecase/get_doctors_usecase.dart';
import '../../features/home/domain/usecase/get_specializations_usecase.dart';
import '../../features/home/presentation/bloc/doctor_list/doctor_list_bloc.dart';
import '../../features/home/presentation/bloc/specialization/specialization_bloc.dart';
import '../../features/doctor_detail/data/datasources/remote/doctor_detail_remote_datasource.dart';
import '../../features/doctor_detail/data/repository/doctor_detail_repository_impl.dart';
import '../../features/doctor_detail/domain/repository/doctor_detail_repository.dart';
import '../../features/doctor_detail/domain/usecase/get_doctor_detail_usecase.dart';
import '../../features/doctor_detail/presentation/bloc/doctor_detail_bloc.dart';
import '../../features/booking/data/datasources/remote/booking_remote_datasource.dart';
import '../../features/booking/data/repository/booking_repository_impl.dart';
import '../../features/booking/domain/repository/booking_repository.dart';
import '../../features/booking/domain/usecase/book_appointment_usecase.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/appointments/data/datasources/remote/appointments_remote_datasource.dart';
import '../../features/appointments/data/repository/appointments_repository_impl.dart';
import '../../features/appointments/domain/repository/appointments_repository.dart';
import '../../features/appointments/domain/usecase/cancel_appointment_usecase.dart';
import '../../features/appointments/domain/usecase/get_appointments_usecase.dart';
import '../../features/appointments/presentation/bloc/appointment_list_bloc.dart';
import '../../features/health_records/data/datasources/remote/health_records_remote_datasource.dart';
import '../../features/health_records/data/repository/health_records_repository_impl.dart';
import '../../features/health_records/domain/repository/health_records_repository.dart';
import '../../features/health_records/domain/usecase/get_health_records_usecase.dart';
import '../../features/health_records/domain/usecase/upload_health_record_usecase.dart';
import '../../features/health_records/presentation/bloc/health_records_bloc.dart';
import '../../features/medicine/data/datasources/remote/medicine_remote_datasource.dart';
import '../../features/medicine/data/repository/medicine_repository_impl.dart';
import '../../features/medicine/domain/repository/medicine_repository.dart';
import '../../features/medicine/domain/usecase/add_medicine_usecase.dart';
import '../../features/medicine/domain/usecase/get_medicines_usecase.dart';
import '../../features/medicine/domain/usecase/mark_medicine_taken_usecase.dart';
import '../../features/medicine/presentation/bloc/medicine_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  _registerCore();
  _registerAuthModule();
  _registerProfileModule();
  _registerHomeModule();
  _registerDoctorDetailModule();
  _registerBookingModule();
  _registerAppointmentsModule();
  _registerHealthRecordsModule();
  _registerMedicineModule();
}

void _registerCore() {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<LocalJsonStore>(() => FileLocalJsonStore());
  sl.registerLazySingleton<MockApiClient>(() => MockApiClient(store: sl()));
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl()),
  );
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
  // Usecases — reuse AuthRepository, no dedicated ProfileRepository
  sl.registerLazySingleton(() => GetProfileUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => UpdateProfileUsecase(authRepository: sl()));

  // Bloc — screen-scoped, unlike AuthBloc nothing outside the Profile tab needs it
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUsecase: sl(),
      updateProfileUsecase: sl(),
    ),
  );

  // Payment history — data sources / repository
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(paymentRemoteDataSource: sl()),
  );

  // Usecase
  sl.registerLazySingleton(() => GetPaymentsUsecase(repository: sl()));

  // Bloc — screen-scoped, one instance per Payment History screen visit
  sl.registerFactory(() => PaymentHistoryBloc(getPaymentsUsecase: sl()));
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

void _registerDoctorDetailModule() {
  // Data sources / repository
  sl.registerLazySingleton<DoctorDetailRemoteDataSource>(
    () => DoctorDetailRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<DoctorDetailRepository>(
    () => DoctorDetailRepositoryImpl(doctorDetailRemoteDataSource: sl()),
  );

  // Usecase
  sl.registerLazySingleton(() => GetDoctorDetailUsecase(repository: sl()));

  // Bloc — screen-scoped, one instance per doctor detail visit
  sl.registerFactory(() => DoctorDetailBloc(getDoctorDetailUsecase: sl()));
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

void _registerAppointmentsModule() {
  // Data sources / repository
  sl.registerLazySingleton<AppointmentsRemoteDataSource>(
    () => AppointmentsRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(appointmentsRemoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetAppointmentsUsecase(repository: sl()));
  sl.registerLazySingleton(() => CancelAppointmentUsecase(repository: sl()));

  // Bloc — screen-scoped, one instance per visit to the Appointments tab
  sl.registerFactory(
    () => AppointmentListBloc(
      getAppointmentsUsecase: sl(),
      cancelAppointmentUsecase: sl(),
    ),
  );
}

void _registerHealthRecordsModule() {
  // Data sources / repository
  sl.registerLazySingleton<HealthRecordsRemoteDataSource>(
    () => HealthRecordsRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<HealthRecordsRepository>(
    () => HealthRecordsRepositoryImpl(healthRecordsRemoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetHealthRecordsUsecase(repository: sl()));
  sl.registerLazySingleton(() => UploadHealthRecordUsecase(repository: sl()));

  // Bloc — one instance per screen visit
  sl.registerFactory(
    () => HealthRecordsBloc(
      getHealthRecordsUsecase: sl(),
      uploadHealthRecordUsecase: sl(),
    ),
  );
}

void _registerMedicineModule() {
  // Data sources / repository
  sl.registerLazySingleton<MedicineRemoteDataSource>(
    () => MedicineRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<MedicineRepository>(
    () => MedicineRepositoryImpl(medicineRemoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetMedicinesUsecase(repository: sl()));
  sl.registerLazySingleton(() => AddMedicineUsecase(repository: sl()));
  sl.registerLazySingleton(() => MarkMedicineTakenUsecase(repository: sl()));

  // Bloc — screen-scoped, kept alive by MainShell's IndexedStack, and
  // reused across list/add screens via BlocProvider.value.
  sl.registerFactory(
    () => MedicineBloc(
      getMedicinesUsecase: sl(),
      addMedicineUsecase: sl(),
      markMedicineTakenUsecase: sl(),
      notificationService: sl(),
    ),
  );
}
