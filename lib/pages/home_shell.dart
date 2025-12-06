import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_scope.dart';

class HomeShell extends StatefulWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _isMenuVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = AuthScope.of(context);

    final currentLocation = GoRouterState.of(context).uri.toString();

    final items = <_MenuItem>[
     _MenuItem(
    icon: Icons.dashboard_outlined,
    label: 'Dashboard',
    location: '/',
  ),
  _MenuItem(
    icon: Icons.account_balance_wallet_outlined,
    label: 'Contas dos Usuários',
    location: '/accounts-users',
  ),
  _MenuItem(
    icon: Icons.grid_view,
    label: 'Modulos',
    location: '/modules',
  ),
  _MenuItem(
    icon: Icons.people_alt_outlined,
    label: 'Usuários',
    location: '/usuarios',
  ),
  _MenuItem(
    icon: Icons.settings_outlined,
    label: 'Configurações',
    location: '/settings',
  ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        if (!isWide) {
          return Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              title: const Text('Back Office'),
              elevation: 1,
              scrolledUnderElevation: 0,
              actions: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.green.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      auth.userName ?? 'Usuário',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      tooltip: 'Sair',
                      onPressed: () {
                        auth.logout();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ],
            ),
            drawer: Drawer(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Menu',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final selected = index ==
                              _selectedIndex(currentLocation, items);
                          return ListTile(
                            leading: Icon(item.icon),
                            title: Text(item.label),
                            selected: selected,
                            onTap: () {
                              if (currentLocation != item.location) {
                                context.go(item.location);
                              }
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
          );
        }

        final showRail = _isMenuVisible;
        final extendedRail = constraints.maxWidth >= 1200 && _isMenuVisible;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                _isMenuVisible ? Icons.chevron_left : Icons.chevron_right,
              ),
              onPressed: () {
                setState(() {
                  _isMenuVisible = !_isMenuVisible;
                });
              },
            ),
            title: const Text('Back Office'),
            elevation: 1,
            scrolledUnderElevation: 0,
            actions: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    auth.userName ?? 'Usuário',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    tooltip: 'Sair',
                    onPressed: () {
                      auth.logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ],
          ),
          body: Row(
            children: [
              if (showRail)
                NavigationRail(
                  selectedIndex: _selectedIndex(currentLocation, items),
                  extended: extendedRail,
                  onDestinationSelected: (index) {
                    final item = items[index];
                    if (currentLocation != item.location) {
                      context.go(item.location);
                    }
                  },
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _selectedIndex(String currentLocation, List<_MenuItem> items) {
    final index = items.indexWhere((e) => e.location == currentLocation);
    return index < 0 ? 0 : index;
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String location;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.location,
  });
}
