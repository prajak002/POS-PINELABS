import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../models/auth_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final AuthService _authService;

  AuthNotifier(this._apiClient, this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: user != null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final loginRequest = LoginRequest(username: username, password: password);
      final response = await _apiClient.login(loginRequest);

      if (response.success && response.token.isNotEmpty) {
        // First try to use the user data from the API response
        User? user = response.user;
        
        // If no user data in response, decode from JWT token
        if (user == null) {
          user = _authService.decodeToken(response.token);
        }
        
        if (user != null) {
          await _authService.saveToken(response.token);
          await _authService.saveUserRole(user.role);
          await _authService.saveUsername(user.username);
          
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
          return true;
        } else {
          state = state.copyWith(
            error: 'Invalid token or user data received',
            isLoading: false,
          );
          return false;
        }
      } else {
        state = state.copyWith(
          error: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Login failed: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final dioProvider = Provider<Dio>((ref) {
  return DioClient.createDio();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(apiClient, authService);
});
