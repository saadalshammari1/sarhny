import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import 'api_providers.dart';
import 'storage_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.username,
  });
  final AuthStatus status;
  final int? userId;
  final String? username;

  AuthState copyWith({
    AuthStatus? status,
    int? userId,
    String? username,
  }) =>
      AuthState(
        status: status ?? this.status,
        userId: userId ?? this.userId,
        username: username ?? this.username,
      );
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final secure = ref.watch(secureStorageProvider);
  return AuthRepository(dio, secure);
});

class AuthStateNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(secureStorageProvider);
    final hasSession = await storage.hasSession();
    final userId = await storage.readUserId();
    return AuthState(
      status: hasSession
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      userId: userId,
    );
  }

  Future<void> markAuthenticated({
    required int userId,
    String? username,
  }) async {
    state = AsyncData(
      AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
        username: username,
      ),
    );
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> clearSession() async {
    await ref.read(secureStorageProvider).clear();
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);
