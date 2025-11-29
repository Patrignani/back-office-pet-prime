import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'auth/auth_state.dart';
import 'auth/auth_scope.dart';

class BackOfficeApp extends StatefulWidget {
  const BackOfficeApp({super.key});

  @override
  State<BackOfficeApp> createState() => _BackOfficeAppState();
}

class _BackOfficeAppState extends State<BackOfficeApp> {
  late final AuthState _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthState();
    _router = createRouter(_auth);
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // tira o cardTheme por enquanto pra não dar erro de tipo
    );

    return AuthScope(
      notifier: _auth,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Back Office',
        theme: theme,
        routerConfig: _router,
      ),
    );
  }
}
