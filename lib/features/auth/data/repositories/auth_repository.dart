import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _storageService;

  AuthRepository(this._dioClient, this._storageService);

  Future<void> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );

      final authData = AuthResponse.fromJson(response.data);
      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data, 'Giriş yapılırken bir hata oluştu.'));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    int? roleId,
    int? teamId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: RegisterRequest(
          fullName: fullName,
          email: email,
          password: password,
          roleId: roleId,
          teamId: teamId,
        ).toJson(),
      );

      final authData = AuthResponse.fromJson(response.data);
      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data, 'Kayıt olunurken bir hata oluştu.'));
    }
  }

  /// Backend'den gelen hatayı (List, Map veya String) güvenli şekilde metne dönüştürür.
  String _extractErrorMessage(dynamic data, String defaultMsg) {
    if (data == null) return defaultMsg;

    if (data is String) return data;

    if (data is List && data.isNotEmpty) {
      final firstError = data.first;
      if (firstError is Map) {
        return firstError['description'] ?? firstError['message'] ?? firstError.values.first.toString();
      }
      return firstError.toString();
    }

    if (data is Map) {
      return data['message'] ?? data['title'] ?? data['error'] ?? defaultMsg;
    }

    return defaultMsg;
  }
}