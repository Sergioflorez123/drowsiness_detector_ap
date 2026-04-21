import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';
=======
import 'package:flutter/material.dart';
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/driving/driving_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/map/live_map_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/stats/stats_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
<<<<<<< HEAD
import 'go_router_refresh.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final path = state.matchedLocation;
      final isAuthRoute = path == '/login' || path == '/register';
      final isSplash = path == '/';

      if (session == null) {
        if (isSplash || isAuthRoute) return null;
        return '/login';
      }
      if (isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/driving',
        builder: (context, state) => const DrivingScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const LiveMapScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
=======
import '../presentation/screens/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorDrivingKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorMapKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorStatsKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDrivingKey,
          routes: [
            GoRoute(
              path: '/driving',
              builder: (context, state) => const DrivingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMapKey,
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const LiveMapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorStatsKey,
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
