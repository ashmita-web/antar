import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    _Dest(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', path: '/citizen/home'),
    _Dest(icon: Icons.mic, selectedIcon: Icons.mic, label: 'Report', path: '/citizen/report'),
    _Dest(icon: Icons.list_alt, selectedIcon: Icons.list_alt, label: 'Requests', path: '/citizen/requests'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _destinations.indexWhere((d) => location.startsWith(d.path));
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Awaaz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_destinations[i].path),
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Dest {
  const _Dest({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
}
