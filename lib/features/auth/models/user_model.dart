class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? venmoHandle;
  final String? profileImageUrl;
  final bool isProfileComplete;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.venmoHandle,
    this.profileImageUrl,
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      venmoHandle: json['venmo_handle'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'venmo_handle': venmoHandle,
      'profile_image_url': profileImageUrl,
      'is_profile_complete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? venmoHandle,
    String? profileImageUrl,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      venmoHandle: venmoHandle ?? this.venmoHandle,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  static UserModel empty() {
    return const UserModel(id: '', email: '');
  }
}
