import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_scope.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

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
        icon: Icons.settings_outlined,
        label: 'Configurações',
        location: '/settings',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final showRail = constraints.maxWidth >= 900;

        return Scaffold(
          appBar: AppBar(
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
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
          body: Row(
            children: [
              if (showRail)
                NavigationRail(
                  selectedIndex: _selectedIndex(currentLocation, items),
                  extended: constraints.maxWidth >= 1200,
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
                  child: child,
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
