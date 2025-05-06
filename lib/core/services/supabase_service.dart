import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billy/core/constants/supabase_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient client;
  late final GoTrueClient auth;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
    client = Supabase.instance.client;
    auth = client.auth;
  }
}
