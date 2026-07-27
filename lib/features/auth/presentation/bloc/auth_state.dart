import 'package:equatable/equatable.dart';

import '../../domain/entity/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  otpSent,
  otpVerifying,
  otpVerified,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? phone;
  final String? message;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phone,
    this.message,
    this.errorMessage,
  });

  const AuthState.initial() : this();

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? phone,
    String? message,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phone: phone ?? this.phone,
      message: message ?? this.message,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, phone, message, errorMessage];
}
