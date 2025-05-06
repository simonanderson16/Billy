import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:billy/core/router/app_router.dart';
import 'package:billy/core/services/dependency_injection.dart';
import 'package:billy/core/theme/app_theme.dart';
import 'package:billy/features/auth/controllers/auth_controller.dart';
import 'package:billy/core/services/supabase_service.dart';
import 'package:billy/core/constants/supabase_constants.dart';
import 'package:storage_client/storage_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load environment variables from .env file
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final supabaseService = SupabaseService();
  await supabaseService.initialize();

  // Initialize dependencies - pass the already created supabaseService instance
  await DependencyInjection.init(supabaseService: supabaseService);

  runApp(
    ProviderScope(
      parent: GetIt.instance<ProviderContainer>(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billy',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splashRoute,
    );
  }
}
