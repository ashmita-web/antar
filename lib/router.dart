import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config.dart';
import 'core/providers.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/dashboard/dashboard_shell.dart';
import 'features/dashboard/home_screen.dart';
import 'features/map/gap_map_screen.dart';
import 'features/quadrant/quadrant_screen.dart';
import 'features/sandbox/budget_sandbox_screen.dart';
import 'features/impact/impact_screen.dart';
import 'features/citizen/citizen_shell.dart';
import 'features/citizen/citizen_home_screen.dart';
import 'features/citizen/report_screen.dart';
import 'features/citizen/my_requests_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final mode = ref.watch(appModeProvider);

  return GoRouter(
    initialLocation: mode == null ? '/welcome' : _homeFor(mode),
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // Official mode — MP Console with bottom nav / rail
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/official/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/official/map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GapMapScreen(),
            ),
          ),
          GoRoute(
            path: '/official/quadrant',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuadrantScreen(),
            ),
          ),
          GoRoute(
            path: '/official/budget',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BudgetSandboxScreen(),
            ),
          ),
          GoRoute(
            path: '/official/impact',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ImpactScreen(),
            ),
          ),
        ],
      ),
      // Citizen mode
      ShellRoute(
        builder: (context, state, child) => CitizenShell(child: child),
        routes: [
          GoRoute(
            path: '/citizen/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CitizenHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/citizen/report',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportScreen(),
            ),
          ),
          GoRoute(
            path: '/citizen/requests',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyRequestsScreen(),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final onWelcome = state.matchedLocation == '/welcome';
      if (mode == null && !onWelcome) return '/welcome';
      if (mode != null && onWelcome) return _homeFor(mode);
      return null;
    },
  );
});

String _homeFor(AppMode mode) => switch (mode) {
  AppMode.citizen => '/citizen/home',
  AppMode.official => '/official/home',
};