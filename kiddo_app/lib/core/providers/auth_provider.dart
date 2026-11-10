import 'package:flutter_riverpod/legacy.dart';
import 'package:kiddo_app/core/services/api_service.dart';
import 'package:kiddo_app/core/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GoogleAuthResult {
  final bool isNewUser;
  final bool hasCompletedOnboarding;
  final UserModel user;

  GoogleAuthResult({
    required this.isNewUser,
    required this.hasCompletedOnboarding,
    required this.user,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthNotifier() : super(const AuthState()) {
    checkAuthStatus();
  }

  /// Check if a valid JWT token exists in secure storage.
  Future<void> checkAuthStatus() async {
    try {
      final token = await _api.getToken();
      if (token == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      // Verify token is still valid by hitting /auth/me
      final response = await _api.get('/auth/me');
      final user = response.data['user'] as Map<String, dynamic>;
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: user['_id'] as String,
        clearError: true,
      );
    } catch (_) {
      // Token invalid or server unreachable — clear it
      await _api.clearToken();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Register a new account with name, email, password, age, and gradeClass.
  Future<void> register(
    String name,
    String email,
    String password, {
    int? age,
    String? gradeClass,
  }) async {
    state = state.copyWith(status: AuthStatus.initial, clearError: true);
    try {
      final response = await _api.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (age != null) 'age': age,
          if (gradeClass != null) 'gradeClass': gradeClass,
        },
      );
      final token = response.data['token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      await _api.saveToken(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: user['_id'] as String,
        clearError: true,
      );
    } on DioException catch (e) {
      final message = e.error?.toString() ?? 'Registration failed';
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: message,
      );
      rethrow;
    }
  }

  /// Sign in with email and password.
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.initial, clearError: true);
    try {
      final response = await _api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = response.data['token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      await _api.saveToken(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: user['_id'] as String,
        clearError: true,
      );
    } on DioException catch (e) {
      final message = e.error?.toString() ?? 'Login failed';
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: message,
      );
      rethrow;
    }
  }

  /// Send forgot password reset email
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _api.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return (response.data['message'] as String?) ?? 'Password reset link sent to your email.';
    } on DioException catch (e) {
      final message = e.response?.data?['message']?.toString() ?? e.error?.toString() ?? 'Failed to send reset link';
      throw Exception(message);
    }
  }

  /// Trigger device native Google Account picker bottom sheet and authenticate
  Future<GoogleAuthResult?> signInWithGoogleDevice() async {
    state = state.copyWith(status: AuthStatus.initial, clearError: true);
    try {
      // Force account picker by signing out first
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled account selection
        return null;
      }

      final response = await _api.post(
        '/auth/google',
        data: {
          'email': googleUser.email,
          'name': googleUser.displayName ?? googleUser.email.split('@')[0],
          'googleId': googleUser.id,
          'avatarUrl': googleUser.photoUrl ?? 'assets/images/kido_character.png',
        },
      );

      final token = response.data['token'] as String;
      final userJson = response.data['user'] as Map<String, dynamic>;
      final isNewUser = (response.data['isNewUser'] as bool?) ?? false;
      final hasCompletedOnboarding = (response.data['hasCompletedOnboarding'] as bool?) ??
          (userJson['hasCompletedOnboarding'] as bool?) ??
          false;

      await _api.saveToken(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userJson['_id'] as String,
        clearError: true,
      );

      final userModel = UserModel(
        id: userJson['_id'] as String,
        name: userJson['name'] as String,
        email: userJson['email']?.toString() ?? '',
        avatarUrl: (userJson['avatarUrl'] as String?) ?? 'assets/images/kido_character.png',
        iq: (userJson['iq'] as num?)?.toInt() ?? 0,
        coins: (userJson['coins'] as num?)?.toInt() ?? 0,
        streak: (userJson['streak'] as num?)?.toInt() ?? 0,
        age: (userJson['age'] as num?)?.toInt() ?? 8,
        gradeClass: userJson['gradeClass']?.toString() ?? 'Class 3',
        hasCompletedOnboarding: hasCompletedOnboarding,
      );

      return GoogleAuthResult(
        isNewUser: isNewUser,
        hasCompletedOnboarding: hasCompletedOnboarding,
        user: userModel,
      );
    } catch (e) {
      final message = e is DioException
          ? (e.response?.data?['message']?.toString() ?? e.error?.toString() ?? 'Google Sign-in failed')
          : e.toString();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: message,
      );
      rethrow;
    }
  }

  /// Authenticate with specified Google account details (used directly or via picker sheet)
  Future<GoogleAuthResult> authenticateWithGoogleData({
    required String email,
    required String name,
    String? googleId,
    String? avatarUrl,
  }) async {
    state = state.copyWith(status: AuthStatus.initial, clearError: true);
    try {
      final response = await _api.post(
        '/auth/google',
        data: {
          'email': email,
          'name': name,
          'googleId': googleId ?? 'google_${email.hashCode.abs()}',
          'avatarUrl': avatarUrl ?? 'assets/images/kido_character.png',
        },
      );

      final token = response.data['token'] as String;
      final userJson = response.data['user'] as Map<String, dynamic>;
      final isNewUser = (response.data['isNewUser'] as bool?) ?? false;
      final hasCompletedOnboarding = (response.data['hasCompletedOnboarding'] as bool?) ??
          (userJson['hasCompletedOnboarding'] as bool?) ??
          false;

      await _api.saveToken(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userJson['_id'] as String,
        clearError: true,
      );

      final userModel = UserModel(
        id: userJson['_id'] as String,
        name: userJson['name'] as String,
        email: userJson['email']?.toString() ?? '',
        avatarUrl: (userJson['avatarUrl'] as String?) ?? 'assets/images/kido_character.png',
        iq: (userJson['iq'] as num?)?.toInt() ?? 0,
        coins: (userJson['coins'] as num?)?.toInt() ?? 0,
        streak: (userJson['streak'] as num?)?.toInt() ?? 0,
        age: (userJson['age'] as num?)?.toInt() ?? 8,
        gradeClass: userJson['gradeClass']?.toString() ?? 'Class 3',
        hasCompletedOnboarding: hasCompletedOnboarding,
      );

      return GoogleAuthResult(
        isNewUser: isNewUser,
        hasCompletedOnboarding: hasCompletedOnboarding,
        user: userModel,
      );
    } catch (e) {
      final message = e is DioException
          ? (e.response?.data?['message']?.toString() ?? e.error?.toString() ?? 'Google Sign-in failed')
          : e.toString();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: message,
      );
      rethrow;
    }
  }

  /// Complete survey / onboarding for the current authenticated user
  Future<void> completeOnboarding({
    required String name,
    required int age,
    required String gradeClass,
    String? avatarUrl,
  }) async {
    try {
      await _api.post(
        '/auth/complete-onboarding',
        data: {
          'name': name,
          'age': age,
          'gradeClass': gradeClass,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out and clear the stored JWT.
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _api.clearToken();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      userId: null,
      clearError: true,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
