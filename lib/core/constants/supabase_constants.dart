import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  // Get Supabase credentials from environment variables
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Supabase table names
  static const String usersTable = 'users';

  // Storage buckets
  static const String profileImagesBucket = 'profile-images';
}
