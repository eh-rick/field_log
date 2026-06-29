import 'package:field_log/views/log_form_view.dart';
import 'package:field_log/views/login_view.dart';
import 'package:field_log/views/splash_view.dart';
import 'package:flutter/material.dart';
import '../views/dashboard_view.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String logForm = '/log-form';
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardView());
      case logForm:
        return MaterialPageRoute(builder: (_) => const LogFormView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}