import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const AuthRegisterSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}

class AuthOtpRequested extends AuthEvent {
  final String phone;

  const AuthOtpRequested({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class AuthOtpVerified extends AuthEvent {
  final String phone;
  final String otp;

  const AuthOtpVerified({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
