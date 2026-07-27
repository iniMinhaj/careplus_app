// core/storage/token_manager.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenManager {
  Future<void> saveTokens({required String accessToken});
  Future<String?> getAccessToken();
  Future<bool> hasStoredToken();
  Future<void> clearTokens();
}

class SecureTokenManager implements TokenManager {
  final FlutterSecureStorage _storage;
  const SecureTokenManager(this._storage);

  static const _accessTokenKey = 'access_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<bool> hasStoredToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
  }
}
