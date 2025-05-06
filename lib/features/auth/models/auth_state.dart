class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? venmoHandle;
  final String? profileImageUrl;
  final bool isProfileComplete;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.displayName,
    this.venmoHandle,
    this.profileImageUrl,
    this.isProfileComplete = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
    String? venmoHandle,
    String? profileImageUrl,
    bool? isProfileComplete,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      venmoHandle: venmoHandle ?? this.venmoHandle,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
