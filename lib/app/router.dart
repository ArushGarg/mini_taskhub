import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../dashboard/dashboard_screen.dart';

class AppRouter {
  // Route name constants
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';

  // Initial route based on auth state
  static String get initialRoute {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null ? dashboard : login;
  }

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen(), settings);

      case signup:
        return _slideRoute(const SignupScreen(), settings);

      case dashboard:
        return _fadeRoute(const DashboardScreen(), settings);

      default:
        return _fadeRoute(const LoginScreen(), settings);
    }
  }

  // Fade transition
  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Slide transition
  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}