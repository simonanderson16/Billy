class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? venmoHandle;
  final String? profileImageUrl;
  final bool isProfileComplete;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.venmoHandle,
    this.profileImageUrl,
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      venmoHandle: json['venmo_handle'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'venmo_handle': venmoHandle,
      'profile_image_url': profileImageUrl,
      'is_profile_complete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? venmoHandle,
    String? profileImageUrl,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      venmoHandle: venmoHandle ?? this.venmoHandle,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
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

  static UserModel empty() {
    return const UserModel(id: '', email: '');
  }
}
