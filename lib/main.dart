import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/mock_api_client.dart';
import 'core/storage/token_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'features/auth/data/repository/auth_repo_impl.dart';
import 'features/auth/domain/repository/auth_repo.dart';
import 'features/auth/domain/usecase/check_auth_status_usecase.dart';
import 'features/auth/domain/usecase/login_usecase.dart';
import 'features/auth/domain/usecase/logout_usecase.dart';
import 'features/auth/domain/usecase/register_usecase.dart';
import 'features/auth/domain/usecase/request_otp_usecase.dart';
import 'features/auth/domain/usecase/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CarePlusApp());
}

AuthRepository _buildAuthRepository() {
  return AuthRepositoryImpl(
    authRemoteDataSource: AuthRemoteDataSourcImpl(apiClient: MockApiClient()),
    tokenManager: const SecureTokenManager(FlutterSecureStorage()),
  );
}

class CarePlusApp extends StatelessWidget {
  const CarePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = _buildAuthRepository();

    return BlocProvider(
      create: (_) => AuthBloc(
        loginUsecase: LoginUsecase(repository: authRepository),
        registerUsecase: RegisterUsecase(authRepository: authRepository),
        requestOtpUsecase: RequestOtpUsecase(authRepository: authRepository),
        verifyOtpUsecase: VerifyOtpUsecase(authRepository: authRepository),
        logoutUsecase: LogoutUsecase(authRepository: authRepository),
        checkAuthStatusUsecase:
            CheckAuthStatusUsecase(authRepository: authRepository),
      )..add(const AuthStatusChecked()),
      child: MaterialApp(
        title: 'CarePlus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainShell(),
        },
      ),
    );
  }
}
