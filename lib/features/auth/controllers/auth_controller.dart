import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billy/features/auth/models/auth_state.dart';
import 'package:billy/features/auth/repositories/auth_repository.dart';

// Provider for AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthController(authRepository: authRepository);
  },
);

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authRepositoryInstanceProvider);
});

// Provider for the actual instance of AuthRepository (will be initialized in main.dart)
final authRepositoryInstanceProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository has not been initialized');
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState());

  // Check and restore authentication state on app start
  Future<void> checkAuth() async {
    state = const AuthState(isLoading: true);

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUserWithProfile();
        if (user != null) {
          state = AuthState(
            isLoading: false,
            isAuthenticated: true,
            userId: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            venmoHandle: user.venmoHandle,
            profileImageUrl: user.profileImageUrl,
            isProfileComplete: user.isProfileComplete,
          );
          return;
        }
      }

      state = const AuthState(isLoading: false, isAuthenticated: false);
    } catch (e) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign up with email and password
  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
      );

      if (user != null) {
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          userId: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          venmoHandle: user.venmoHandle,
          profileImageUrl: user.profileImageUrl,
          isProfileComplete: user.isProfileComplete,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: 'Failed to sign up. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          userId: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          venmoHandle: user.venmoHandle,
          profileImageUrl: user.profileImageUrl,
          isProfileComplete: user.isProfileComplete,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: 'Failed to sign in. Please check your credentials.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.signOut();
      state = const AuthState(isLoading: false, isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String venmoHandle,
    Uint8List? profileImage,
    String? fileName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userId = state.userId;

      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User not found. Please sign in again.',
        );
        return;
      }

      String? profileImageUrl = state.profileImageUrl;

      // Upload profile image if provided
      if (profileImage != null && fileName != null) {
        try {
          profileImageUrl = await _authRepository.uploadProfileImage(
            userId: userId,
            fileBytes: profileImage,
            fileName: fileName,
          );
        } catch (e) {
          // Continue with update even if image upload fails
        }
      }

      // Update user profile
      final updatedUser = await _authRepository.updateUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        venmoHandle: venmoHandle,
        profileImageUrl: profileImageUrl,
      );

      if (updatedUser != null) {
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          userId: updatedUser.id,
          email: updatedUser.email,
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
          venmoHandle: updatedUser.venmoHandle,
          profileImageUrl: updatedUser.profileImageUrl,
          isProfileComplete: updatedUser.isProfileComplete,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update profile. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
