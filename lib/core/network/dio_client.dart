import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient(Ref ref)
      : dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    // AuthInterceptor'a ihtiyaç duyduğu SecureStorageService ve dio instance'ı veriliyor
    dio.interceptors.add(AuthInterceptor(SecureStorageService(), dio));
  }
}

// 1. DioClient Sınıfı Provider'ı
final dioClientProvider = Provider<DioClient>((ref) => DioClient(ref));

// 2. Dio Instance Provider'ı (Servislerde doğrudan 'ref.watch(dioProvider)' ile kullanabilmek için)
final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);