import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';

import '../../../data/datasources/remote/driving_remote_datasource.dart';
import '../../../data/datasources/remote/event_service.dart';
<<<<<<< HEAD
import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
=======
import '../../providers/stats_provider.dart';
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(drivingRemoteDataSourceProvider).logAppOpenedToday();
      await EventService().syncOfflineEvents();
    });
=======
    EventService().syncOfflineEvents();
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Usuario';
<<<<<<< HEAD
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.homeTitle),
=======
    final statsAsyncValue = ref.watch(statsProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
<<<<<<< HEAD
              l.homeGreeting(name),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l.homeSubtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 28),
            _ActionCard(
              title: l.cardDriveTitle,
              subtitle: l.cardDriveSubtitle,
              icon: Icons.directions_car_filled_rounded,
              accent: scheme.primary,
              onTap: () => context.push('/driving'),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              title: l.cardMapTitle,
              subtitle: l.cardMapSubtitle,
              icon: Icons.map_rounded,
              accent: scheme.secondary,
              onTap: () => context.push('/map'),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              title: l.cardStatsTitle,
              subtitle: l.cardStatsSubtitle,
              icon: Icons.insights_rounded,
              accent: scheme.tertiary,
              onTap: () => context.push('/stats'),
=======
              loc.welcomeTitle(name),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              loc.dashboardSummary,
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 32),
            statsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (stats) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScoreCardWidget(stats: stats),
                    const SizedBox(height: 24),
                    _QuickStatTile(
                      title: loc.weeklyEvents,
                      value: stats.totalEvents.toString(),
                      icon: Icons.history,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    _QuickStatTile(
                      title: loc.currentStatus,
                      value: stats.safetyScore >= 80 ? 'Óptimo' : 'Irregular',
                      icon: Icons.monitor_heart,
                      color: stats.safetyScore >= 80 ? theme.colorScheme.secondary : theme.colorScheme.error,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 28),
                      label: Text(loc.startDriving, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      onPressed: () => context.go('/driving'), // Usa el navigation shell
                    )
                  ],
                );
              },
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.statsNoDataBody,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
=======
class _ScoreCardWidget extends StatelessWidget {
  final DriverStats stats;
  const _ScoreCardWidget({required this.stats});
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: isDark ? 2 : 6,
      shadowColor: accent.withOpacity(isDark ? 0.35 : 0.22),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 32, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Theme.of(context).disabledColor,
              ),
            ],
=======
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Text('Puntaje de Descanso y Seguridad', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 16),
          Text(
            '${stats.safetyScore}%',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: stats.safetyScore > 80 ? theme.colorScheme.secondary : (stats.safetyScore > 50 ? Colors.orange : theme.colorScheme.error),
            ),
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
          ),
          const SizedBox(height: 16),
          Text(stats.performanceMessage, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
