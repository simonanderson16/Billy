import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billy/core/router/app_router.dart';
import 'package:billy/core/theme/app_theme.dart';
import 'package:billy/features/auth/controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);

    // Debug print to show auth state
    print(
      'Auth State: isAuthenticated=${authState.isAuthenticated}, isProfileComplete=${authState.isProfileComplete}, displayName=${authState.displayName}',
    );

    if (authState.isAuthenticated) {
      if (authState.isProfileComplete) {
        Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
      } else {
        Navigator.of(
          context,
        ).pushReplacementNamed(AppRouter.completeProfileRoute);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.signInRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 60,
                color: AppTheme.whiteColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Billy',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Split bills with friends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.mediumGrayColor,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
