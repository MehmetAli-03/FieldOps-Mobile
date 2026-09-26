import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/repositories/auth_repository.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

// 1. DÜZELTME: ref parametresi eklendi
final dioClientProvider = Provider((ref) => DioClient(ref));

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.read(dioClientProvider),
    ref.read(secureStorageProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final SecureStorageService _storage;

  AuthNotifier(this._repository, this._storage) : super(const AsyncData(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repository.login(email, password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toString().replaceAll('Exception: ', ''), st);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    int? roleId,
    int? teamId,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        roleId: roleId,
        teamId: teamId,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e.toString().replaceAll('Exception: ', ''), st);
      return false;
    }
  }

  // 2. DÜZELTME: dashboard_page.dart için logout metodu eklendi
  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _storage.deleteToken();
      await _storage.deleteRefreshToken();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString().replaceAll('Exception: ', ''), st);
    }
  }
}