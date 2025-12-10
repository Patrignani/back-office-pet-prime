import 'package:back_office/pages/modules_form_page.dart';
import 'package:back_office/pages/modules_page.dart';
import 'package:back_office/pages/users_page.dart';
import 'package:back_office/widgets/app_form.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'auth/auth_state.dart';
import 'pages/login_page.dart';
import 'pages/home_shell.dart';
import 'pages/dashboard_page.dart';
import 'pages/accounts_user_page.dart';

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
          GoRoute(
              path: '/accounts-users',
              builder: (context, state) => const AccountsUserPage()),
          GoRoute(
              path: '/users', builder: (context, state) => const UserPage()),
          GoRoute(
              path: '/modules',
              builder: (context, state) => const ModulesUserPage()),
          GoRoute(
            path: '/modules/new',
            builder: (context, state) => const ModulesFormPage(
              state: FormScreenState.create,
            ),
          ),
          GoRoute(
            path: '/modules/:id/detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ModulesFormPage(
                state: FormScreenState.view,
                moduleId: id,
              );
            },
          ),
          GoRoute(
            path: '/modules/:id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ModulesFormPage(
                state: FormScreenState.edit,
                moduleId: id,
              );
            },
          ),
        ],
      ),
    ],
  );
}
