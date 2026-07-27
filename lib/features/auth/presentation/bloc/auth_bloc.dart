import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecase/check_auth_status_usecase.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../domain/usecase/register_usecase.dart';
import '../../domain/usecase/request_otp_usecase.dart';
import '../../domain/usecase/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final RequestOtpUsecase _requestOtpUsecase;
  final VerifyOtpUsecase _verifyOtpUsecase;
  final LogoutUsecase _logoutUsecase;
  final CheckAuthStatusUsecase _checkAuthStatusUsecase;

  AuthBloc({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required RequestOtpUsecase requestOtpUsecase,
    required VerifyOtpUsecase verifyOtpUsecase,
    required LogoutUsecase logoutUsecase,
    required CheckAuthStatusUsecase checkAuthStatusUsecase,
  })  : _loginUsecase = loginUsecase,
        _registerUsecase = registerUsecase,
        _requestOtpUsecase = requestOtpUsecase,
        _verifyOtpUsecase = verifyOtpUsecase,
        _logoutUsecase = logoutUsecase,
        _checkAuthStatusUsecase = checkAuthStatusUsecase,
        super(const AuthState.initial()) {
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpVerified>(_onOtpVerified);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _checkAuthStatusUsecase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      (isLoggedIn) => emit(state.copyWith(
        status: isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      )),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _loginUsecase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _registerUsecase(
      RegisterParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (registerResult) {
        emit(state.copyWith(
          status: AuthStatus.registered,
          phone: event.phone,
          message: registerResult.message,
          clearError: true,
        ));
        if (registerResult.requiresOtp) {
          add(AuthOtpRequested(phone: event.phone));
        }
      },
    );
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      phone: event.phone,
      clearError: true,
    ));
    final result = await _requestOtpUsecase(RequestOtpParams(phone: event.phone));
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (message) => emit(state.copyWith(
        status: AuthStatus.otpSent,
        phone: event.phone,
        message: message,
        clearError: true,
      )),
    );
  }

  Future<void> _onOtpVerified(
    AuthOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.otpVerifying, clearError: true));
    final result = await _verifyOtpUsecase(
      VerifyOtpParams(phone: event.phone, otp: event.otp),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (verified) => emit(state.copyWith(
        status: verified ? AuthStatus.otpVerified : AuthStatus.failure,
        errorMessage: verified ? null : 'Invalid OTP, please try again',
        clearError: verified,
      )),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUsecase(const NoParams());
    emit(const AuthState.initial().copyWith(status: AuthStatus.unauthenticated));
  }
}
