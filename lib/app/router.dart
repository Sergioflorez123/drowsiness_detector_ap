import 'package:go_router/go_router.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/driving/driving_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/map/live_map_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/stats/stats_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

final appRouter = GoRouter(
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
      path: '/regaster',
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
