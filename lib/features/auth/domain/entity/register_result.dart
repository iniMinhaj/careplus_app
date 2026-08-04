import 'package:equatable/equatable.dart';

class RegisterResult extends Equatable {
  final String userId;
  final bool requiresOtp;
  final String message;

  const RegisterResult({
    required this.userId,
    required this.requiresOtp,
    required this.message,
  });

  @override
  List<Object?> get props => [userId, requiresOtp, message];
}
