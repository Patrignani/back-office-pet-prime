import 'package:back_office/models/users/users_get_all.dart';
import 'package:flutter/material.dart';
import '../models/paginator.dart';
import '../widgets/user_card.dart';
import '../services/user_service.dart';
import '../auth/auth_scope.dart';
import '../core/exceptions.dart';
import 'package:go_router/go_router.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _showFilters = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();

  String? _selectedControlModule;
  String? _selectedTwoFactore;

  int page = 1;
  int perPage = 12;

  final _service = UserService();

  Paginator<UserGetAll>? paginator;
  bool _loading = false;
  String? _error;

  String _token = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _token = AuthScope.of(context).token ?? '';
      _initialized = true;
      _fetchModules();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _userNameCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchModules() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bool? controlModuleFilter;
      if (_selectedControlModule == 'true') {
        controlModuleFilter = true;
      } else if (_selectedControlModule == 'false') {
        controlModuleFilter = false;
      } else {
        controlModuleFilter = null;
      }

      final bool? twoFactoryFilter;
      if (_selectedTwoFactore == 'true') {
        twoFactoryFilter = true;
      } else if (_selectedTwoFactore == 'false') {
        twoFactoryFilter = false;
      } else {
        twoFactoryFilter = null;
      }

      final result = await _service.getUsers(
        token: _token,
        page: page,
        perPage: perPage,
        name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        userName: _userNameCtrl.text.trim().isEmpty
            ? null
            : _userNameCtrl.text.trim(),
        accountName: _accountNameCtrl.text.trim().isEmpty
            ? null
            : _accountNameCtrl.text.trim(),
        controlModule: controlModuleFilter,
        twoFactory: twoFactoryFilter,
      );

      if (!mounted) return;

      setState(() {
        paginator = result;
      });
    } on SessionExpiredException {
      if (!mounted) return;

      final auth = AuthScope.of(context);
      auth.logout();
      context.go('/login');
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar usuários.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  int get _totalPages {
    if (paginator == null) return 1;
    if (paginator!.totalPage <= 0) return 1;
    return paginator!.totalPage;
  }

  void _applyFilters() {
    setState(() {
      page = 1;
    });
    _fetchModules();
  }

  void _clearFilters() {
    _nameCtrl.clear();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _userNameCtrl.clear();
    _accountNameCtrl.clear();

    setState(() {
      _selectedControlModule = null;
      _selectedTwoFactore = null;
      page = 1;
      perPage = 12;
    });

    _fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final crossAxisCount = isMobile
        ? 1
        : isTablet
            ? 2
            : 3;

    final childAspectRatio = isMobile
        ? 0.9
        : isTablet
            ? 1.1
            : 1.8;

    final items = paginator?.data ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Usuários',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  context.go('/users/new');
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo usuário'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _showFilters = !_showFilters);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showFilters
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        const SizedBox(width: 8),
                        const Text('Filtros de pesquisa'),
                        const Spacer(),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Limpar'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _applyFilters,
                          child: const Text('Aplicar'),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isWide ? 260 : double.infinity,
                              child: TextField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isWide ? 220 : double.infinity,
                              child: TextField(
                                controller: _emailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isWide ? 220 : double.infinity,
                              child: TextField(
                                controller: _userNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nome de acesso',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isWide ? 220 : double.infinity,
                              child: TextField(
                                controller: _accountNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nome da conta',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isWide ? 200 : double.infinity,
                              child: DropdownButtonFormField<String>(
                                value: _selectedControlModule,
                                decoration: const InputDecoration(
                                  labelText: 'Administrador?',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'true',
                                    child: Text('Sim'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'false',
                                    child: Text('Não'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedControlModule = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: isWide ? 200 : double.infinity,
                              child: DropdownButtonFormField<String>(
                                value: _selectedTwoFactore,
                                decoration: const InputDecoration(
                                  labelText: 'Autenticação de dois fatores',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'true',
                                    child: Text('Sim'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'false',
                                    child: Text('Não'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTwoFactore = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: isWide ? 140 : double.infinity,
                              child: DropdownButtonFormField<int>(
                                value: perPage,
                                decoration: const InputDecoration(
                                  labelText: 'Por página',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 6,
                                    child: Text('6'),
                                  ),
                                  DropdownMenuItem(
                                    value: 12,
                                    child: Text('12'),
                                  ),
                                  DropdownMenuItem(
                                    value: 24,
                                    child: Text('24'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    perPage = value;
                                    page = 1;
                                  });
                                  _fetchModules();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  crossFadeState: _showFilters
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(_error!),
              ),
            )
          else if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Nenhum usuário encontrado.'),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (_, index) {
                final user = items[index];
                return UserCard(
                  token: _token,
                  item: user,
                  onPressed: () {
                    context.go('/users/${user.id}/detail');
                  },
                  onMore: () {
                    context.go('/users/${user.id}/edit');
                  },
                );
              },
            ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Página $page de $_totalPages',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _PageIconButton(
                      icon: Icons.chevron_left,
                      enabled: page > 1,
                      onTap: () {
                        if (page <= 1) return;
                        setState(() {
                          page--;
                        });
                        _fetchModules();
                      },
                    ),
                    const SizedBox(width: 4),
                    _PageIconButton(
                      icon: Icons.chevron_right,
                      enabled: page < _totalPages,
                      onTap: () {
                        if (page >= _totalPages) return;
                        setState(() {
                          page++;
                        });
                        _fetchModules();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? theme.colorScheme.primary.withOpacity(0.06)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
