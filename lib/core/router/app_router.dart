import 'package:flutter/material.dart';
import 'package:billy/features/auth/screens/splash_screen.dart';
import 'package:billy/features/auth/screens/sign_in_screen.dart';
import 'package:billy/features/auth/screens/sign_up_screen.dart';
import 'package:billy/features/auth/screens/complete_profile_screen.dart';
import 'package:billy/features/profile/screens/profile_screen.dart';
import 'package:billy/features/profile/screens/edit_profile_screen.dart';
import 'package:billy/features/home/screens/home_screen.dart';
import 'package:billy/features/history/screens/history_screen.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String signInRoute = '/sign-in';
  static const String signUpRoute = '/sign-up';
  static const String completeProfileRoute = '/complete-profile';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/edit-profile';
  static const String homeRoute = '/home';
  static const String historyRoute = '/history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case signInRoute:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case signUpRoute:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case completeProfileRoute:
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfileRoute:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case historyRoute:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
