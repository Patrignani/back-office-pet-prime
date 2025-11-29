
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'auth/auth_state.dart';
import 'pages/login_page.dart';
import 'pages/home_shell.dart';
import 'pages/dashboard_page.dart';

GoRouter createRouter(AuthState auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final logged = auth.isLoggedIn;
      final logging = state.matchedLocation == '/login';
      if (!logged && !logging) return '/login';
      if (logged && logging) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
        ],
      ),
    ],
  );
}
