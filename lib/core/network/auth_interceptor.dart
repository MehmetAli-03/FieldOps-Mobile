import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains(ApiEndpoints.refresh)) {
      try {
        final refreshToken = await _storage.getRefreshToken();
        final accessToken = await _storage.getAccessToken();

        if (refreshToken != null && accessToken != null) {
          // Refresh token isteği
          final response = await _dio.post(
            ApiEndpoints.refresh,
            data: {
              'accessToken': accessToken,
              'refreshToken': refreshToken,
            },
          );

          final newAccessToken = response.data['data']['accessToken'];
          final newRefreshToken = response.data['data']['refreshToken'];

          await _storage.saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);

          // Yarım kalan orijinal isteği yeni token ile tekrarla
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          final clonedRequest = await _dio.request(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );

          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        await _storage.clearTokens();
      }
    }
    return handler.next(err);
  }
}