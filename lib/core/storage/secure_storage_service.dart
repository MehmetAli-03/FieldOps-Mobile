import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Access Token Metodları
  Future<void> saveToken(String token) async => await _storage.write(key: _accessTokenKey, value: token);
  Future<String?> getToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<void> deleteToken() async => await _storage.delete(key: _accessTokenKey);

  // Refresh Token Metodları
  Future<void> saveRefreshToken(String token) async => await _storage.write(key: _refreshTokenKey, value: token);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  Future<void> deleteRefreshToken() async => await _storage.delete(key: _refreshTokenKey);

  // İki Token'ı Birden Kaydetme (AuthRepository için)
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Token'ları Temizleme (AuthInterceptor & Logout için)
  Future<void> clearTokens() async => await _storage.deleteAll();
  Future<void> clearAll() async => await _storage.deleteAll();
}