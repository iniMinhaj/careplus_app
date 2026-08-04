import 'package:careplus/core/network/mock_api_client.dart';
import 'package:careplus/features/auth/data/models/auth_response_model.dart';
import 'package:careplus/features/auth/data/models/register_response_model.dart';
import 'package:careplus/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login(
      {required String email, required String password});
  Future<RegisterResponseModel> register(
      {required String name,
      required String email,
      required String phone,
      required String password});
  Future<String> requestOtp({required String phone});
  Future<bool> verifyOtp({required String phone, required String otp});
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourcImpl implements AuthRemoteDataSource {
  final MockApiClient _apiClient;

  AuthRemoteDataSourcImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;
  @override
  Future<AuthResponseModel> login(
      {required String email, required String password}) async {
    final response = await _apiClient.load("auth.json");
    return AuthResponseModel.fromJson(response['login_success']);
  }

  @override
  Future<RegisterResponseModel> register(
      {required String name,
      required String email,
      required String phone,
      required String password}) async {
    final response = await _apiClient.load("auth.json");
    return RegisterResponseModel.fromJson(response['register_success']);
  }

  @override
  Future<String> requestOtp({required String phone}) async {
    final response = await _apiClient.load("auth.json");
    return response['otp_request']['otpReference'];
  }

  @override
  Future<bool> verifyOtp({required String phone, required String otp}) async {
    final response = await _apiClient.load("auth.json");
    return response["otp_verify_success"]["verified"];
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.load("user.json");
    return UserModel.fromJson(response['current_user']);
  }
}
