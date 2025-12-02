import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_scope.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passwordCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final auth = AuthScope.of(context);
    final ok = await auth.login(
      _userCtrl.text.trim(),
      _passwordCtrl.text,
      _tokenCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      context.go('/');
    } else {
      setState(() {
        _error = 'Credenciais inválidas.';
        _isSubmitting = false;
      });
    }
  }

  Widget _buildLogoSection({required bool isMobile}) {
    final borderRadius = isMobile
        ? const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          )
        : const BorderRadius.horizontal(
            left: Radius.circular(24),
          );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 24 : 32,
          horizontal: isMobile ? 16 : 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: isMobile ? 160 : 350,
              height: isMobile ? 160 : 350,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            const Text(
              'Sistema de Backoffice',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(ThemeData theme, {required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bem-vindo 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entre com suas credenciais para continuar.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onFieldSubmitted: (value) => _submit(),
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'User',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o usuário';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  onFieldSubmitted: (value) => _submit(),
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  onFieldSubmitted: (value) => _submit(),
                  textInputAction: TextInputAction.done,
                  controller: _tokenCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Token',
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o token';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  onFieldSubmitted: (value) => _submit(),
                  textInputAction: TextInputAction.done,
                  controller: _tokenCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Token',
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o token';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 20,
                  child: _error != null
                      ? Text(
                          _error!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1D4ED8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: isMobile
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogoSection(isMobile: true),
                          _buildFormSection(theme, isMobile: true),
                        ],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(24),
                                ),
                                child: _buildLogoSection(isMobile: false),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: _buildFormSection(theme, isMobile: false),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
