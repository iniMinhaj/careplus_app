import 'package:careplus/core/network/mock_api_client.dart';
import 'package:careplus/features/auth/data/models/auth_response_model.dart';
import 'package:careplus/features/auth/data/models/register_response_model.dart';
import 'package:careplus/features/auth/data/models/user_model.dart';

/// Thrown by [AuthRemoteDataSource.login] when no stored user matches the
/// submitted email/password — a distinct condition from a generic failure so
/// the repository can map it to a specific [AuthFailure].
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

/// Thrown by [AuthRemoteDataSource.register] when the email is already taken.
class EmailAlreadyInUseException implements Exception {
  const EmailAlreadyInUseException();
}

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
  Future<UserModel> getCurrentUser({String? userId});
}

class AuthRemoteDataSourcImpl implements AuthRemoteDataSource {
  final MockApiClient _apiClient;

  AuthRemoteDataSourcImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> login(
      {required String email, required String password}) async {
    final response = await _apiClient.load('users.json');
    final users = (response['users'] as List).cast<Map<String, dynamic>>();

    Map<String, dynamic>? match;
    for (final user in users) {
      if (user['email'] == email && user['password'] == password) {
        match = user;
        break;
      }
    }
    if (match == null) {
      throw const InvalidCredentialsException();
    }

    return AuthResponseModel(
      accessToken: 'mock.token.${match['id']}',
      user: UserModel.fromJson(match),
    );
  }

  @override
  Future<RegisterResponseModel> register(
      {required String name,
      required String email,
      required String phone,
      required String password}) async {
    final response = await _apiClient.load('users.json');
    final users = (response['users'] as List).cast<Map<String, dynamic>>();

    if (users.any((user) => user['email'] == email)) {
      throw const EmailAlreadyInUseException();
    }

    final newUser = <String, dynamic>{
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
      'phone': phone,
      // Mock-only: a real backend would hash this before storing it.
      'password': password,
      'photoUrl': 'https://i.pravatar.cc/150?u=$email',
      'dateOfBirth': '',
      'gender': '',
      'bloodGroup': '',
      'address': '',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _apiClient.save('users.json', {
      ...response,
      'users': [...users, newUser],
    });

    return RegisterResponseModel(
      message: 'Account created successfully. Please verify your phone number.',
      userId: newUser['id'] as String,
      requiresOtp: true,
    );
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
  Future<UserModel> getCurrentUser({String? userId}) async {
    final response = await _apiClient.load('users.json');
    final users = (response['users'] as List).cast<Map<String, dynamic>>();

    Map<String, dynamic>? match;
    if (userId != null) {
      for (final user in users) {
        if (user['id'] == userId) {
          match = user;
          break;
        }
      }
    }
    return UserModel.fromJson(match ?? users.first);
  }
}
