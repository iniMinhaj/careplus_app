import 'package:careplus/features/auth/domain/entity/register_result.dart';

class RegisterResponseModel {
  final String message;
  final String userId;
  final bool requiresOtp;

  const RegisterResponseModel({
    required this.message,
    required this.userId,
    required this.requiresOtp,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] as String,
      userId: json['userId'] as String,
      requiresOtp: json['requiresOtp'] as bool,
    );
  }

  RegisterResult toEntity() => RegisterResult(
        userId: userId,
        requiresOtp: requiresOtp,
        message: message,
      );
}
