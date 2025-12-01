import 'package:flutter/material.dart';
import '../models/account_get_all.dart';
import '../models/paginator.dart';
import '../widgets/account_card.dart';
import '../services/account_service.dart';
import '../auth/auth_scope.dart';
import '../core/exceptions.dart';
import 'package:go_router/go_router.dart';


class AccountsUserPage extends StatefulWidget {
  const AccountsUserPage({super.key});

  @override
  State<AccountsUserPage> createState() => _AccountsUserPageState();
}

class _AccountsUserPageState extends State<AccountsUserPage> {
  bool _showFilters = false;

  final _nameCtrl = TextEditingController();
  final _createdAtCtrl = TextEditingController();
  final _statusUpdatedAtCtrl = TextEditingController();

  String? _selectedStatusId;
  DateTime? _createdAt;
  DateTime? _statusUpdatedAt;

  int page = 1;
  int perPage = 12;

  final _service = AccountService();

  Paginator<AccountGetAll>? paginator;
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
    _fetchAccounts();
  }
}

@override
void initState() {
  super.initState();
}

  @override
  void dispose() {
    _nameCtrl.dispose();
    _createdAtCtrl.dispose();
    _statusUpdatedAtCtrl.dispose();
    super.dispose();
  }

Future<void> _fetchAccounts() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final result = await _service.getAccounts(
      token: _token,
      page: page,
      perPage: perPage,
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      statusId:
          _selectedStatusId != null ? int.parse(_selectedStatusId!) : null,
      createdAt: _createdAt,
      statusUpdatedAt: _statusUpdatedAt,
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
      _error = 'Erro ao carregar contas.';
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

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime? current,
    required ValueChanged<DateTime?> onChanged,
  }) async {
    final now = DateTime.now();
    final initial = current ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
      onChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return "$d/$m/$y";
  }

  void _applyFilters() {
    setState(() {
      page = 1;
    });
    _fetchAccounts();
  }

  void _clearFilters() {
    setState(() {
      _nameCtrl.clear();
      _createdAtCtrl.clear();
      _statusUpdatedAtCtrl.clear();
      _selectedStatusId = null;
      _createdAt = null;
      _statusUpdatedAt = null;
      page = 1;
    });
    _fetchAccounts();
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
        ? 1.4
        : isTablet
            ? 1.1
            : 1.6;

    final items = paginator?.data ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contas dos Usuários",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          _showFilters
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        const SizedBox(width: 8),
                        const Text("Filtros de pesquisa"),
                        const Spacer(),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text("Limpar"),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _applyFilters,
                          child: const Text("Aplicar"),
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
                        final filtersIsWide = constraints.maxWidth > 700;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width:
                                  filtersIsWide ? 260 : double.infinity,
                              child: TextField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: "Nome",
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  filtersIsWide ? 200 : double.infinity,
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatusId,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('Ativo'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('Inativo'),
                                  ),
                                  DropdownMenuItem(
                                    value: '3',
                                    child: Text('Pendente'),
                                  ),
                                  DropdownMenuItem(
                                    value: '4',
                                    child: Text('Bloqueado'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatusId = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width:
                                  filtersIsWide ? 200 : double.infinity,
                              child: TextField(
                                controller: _createdAtCtrl,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Criado em',
                                  suffixIcon: Icon(Icons.date_range),
                                ),
                                onTap: () {
                                  _pickDate(
                                    controller: _createdAtCtrl,
                                    current: _createdAt,
                                    onChanged: (value) {
                                      setState(() {
                                        _createdAt = value;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width:
                                  filtersIsWide ? 220 : double.infinity,
                              child: TextField(
                                controller: _statusUpdatedAtCtrl,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Status atualizado em',
                                  suffixIcon: Icon(Icons.date_range),
                                ),
                                onTap: () {
                                  _pickDate(
                                    controller: _statusUpdatedAtCtrl,
                                    current: _statusUpdatedAt,
                                    onChanged: (value) {
                                      setState(() {
                                        _statusUpdatedAt = value;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width:
                                  filtersIsWide ? 140 : double.infinity,
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
                                  _fetchAccounts();
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
                  child: Text("Nenhuma conta encontrada."),
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
                return AccountCard(
                  item: items[index],
                  onPressed: () {},
                  onMore: () {},
                );
              },
            ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    "Página $page de $_totalPages",
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
                      _fetchAccounts();
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
                      _fetchAccounts();
                    },
                  ),
                ],
              ),
            ),
          ),
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
