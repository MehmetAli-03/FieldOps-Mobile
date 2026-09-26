import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/repositories/auth_repository.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());
final dioClientProvider = Provider((ref) => DioClient());

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.read(dioClientProvider),
    ref.read(secureStorageProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncData(null));

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
}