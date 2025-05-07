import 'dart:typed_data';
import 'package:billy/core/services/supabase_service.dart';
import 'package:billy/features/auth/models/user_model.dart';
import 'package:billy/core/constants/supabase_constants.dart';
import 'package:http/http.dart' as http;
import 'package:storage_client/storage_client.dart';

class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository({required SupabaseService supabaseService})
    : _supabaseService = supabaseService;

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email ?? '',
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await _getUserProfile(response.user!.id);
        return userData;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    try {
      final user = _supabaseService.auth.currentUser;
      if (user != null) {
        // Use async/await in a synchronous context by returning a placeholder and updating later
        _getUserProfile(user.id).then((fullProfile) {
          return fullProfile;
        });
        // Return basic user for now
        return UserModel(id: user.id, email: user.email ?? '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current user with full profile data
  Future<UserModel?> getCurrentUserWithProfile() async {
    try {
      final user = _supabaseService.auth.currentUser;
      if (user != null) {
        return await _getUserProfile(user.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current user session
  Future<bool> isAuthenticated() async {
    try {
      final session = _supabaseService.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  // Get user profile data from Supabase
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final response =
          await _supabaseService.client
              .from(SupabaseConstants.usersTable)
              .select()
              .eq('id', userId)
              .single();

      // Response is never null, proceed directly
      final user = _supabaseService.auth.currentUser;
      if (user != null) {
        final userModel = UserModel(
          id: user.id,
          email: user.email ?? '',
          firstName: response['first_name'],
          lastName: response['last_name'],
          venmoHandle: response['venmo_handle'],
          profileImageUrl: response['profile_image_url'],
          isProfileComplete: response['is_profile_complete'] ?? false,
        );

        return userModel;
      }

      return null;
    } catch (e) {
      // Return basic user if profile retrieval fails
      final user = _supabaseService.auth.currentUser;
      if (user != null) {
        return UserModel(id: user.id, email: user.email ?? '');
      }
      return null;
    }
  }

  // Update user profile
  Future<UserModel?> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? venmoHandle,
    String? profileImageUrl,
  }) async {
    try {
      // Get current user to retrieve email
      final user = _supabaseService.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = {
        'id': userId,
        'email': user.email,
        'first_name': firstName,
        'last_name': lastName,
        'venmo_handle': venmoHandle,
        'profile_image_url': profileImageUrl,
        'is_profile_complete': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.client
          .from(SupabaseConstants.usersTable)
          .upsert(updateData)
          .select();

      return await _getUserProfile(userId);
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      // Generate a more reliable file name using time-based suffix
      final safeFileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$safeFileName';

      // Delete any existing files if needed to avoid conflicts
      try {
        final fileList = await _supabaseService.client.storage
            .from(SupabaseConstants.profileImagesBucket)
            .list(path: userId);

        if (fileList.isNotEmpty) {
          for (final file in fileList) {
            if (file.name.startsWith('profile_')) {
              await _supabaseService.client.storage
                  .from(SupabaseConstants.profileImagesBucket)
                  .remove(['$userId/${file.name}']);
            }
          }
        }
      } catch (e) {
        // Continue with upload even if cleanup fails
      }

      await _supabaseService.client.storage
          .from(SupabaseConstants.profileImagesBucket)
          .uploadBinary(filePath, fileBytes);

      final imageUrl = _supabaseService.client.storage
          .from(SupabaseConstants.profileImagesBucket)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }
}
