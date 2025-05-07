class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? venmoHandle;
  final String? profileImageUrl;
  final bool isProfileComplete;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
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
    String? firstName,
    String? lastName,
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
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      venmoHandle: venmoHandle ?? this.venmoHandle,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper method to get full name
  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName;
    } else if (lastName != null) {
      return lastName;
    }
    return null;
  }
}
