import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/driving/driving_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/map/live_map_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/stats/stats_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
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
