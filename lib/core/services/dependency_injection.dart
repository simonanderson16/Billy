import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billy/core/services/supabase_service.dart';
import 'package:billy/features/auth/repositories/auth_repository.dart';
import 'package:billy/features/auth/controllers/auth_controller.dart';

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init({SupabaseService? supabaseService}) async {
    // Services
    if (supabaseService != null) {
      // Use the provided instance if available
      getIt.registerSingleton<SupabaseService>(supabaseService);
    } else {
      // Create a new instance if not provided
      getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());

      // Initialize Supabase (only needed if we created a new instance)
      await getIt<SupabaseService>().initialize();
    }

    // Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(supabaseService: getIt<SupabaseService>()),
    );

    // Providers
    final container = ProviderContainer(
      overrides: [
        authRepositoryInstanceProvider.overrideWithValue(
          getIt<AuthRepository>(),
        ),
      ],
    );
    getIt.registerSingleton<ProviderContainer>(container);
  }
}
