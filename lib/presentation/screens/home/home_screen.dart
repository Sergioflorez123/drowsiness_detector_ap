import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';

import '../../../data/datasources/remote/event_service.dart';
import '../../providers/stats_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    EventService().syncOfflineEvents();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Usuario';
    final statsAsyncValue = ref.watch(statsProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCardWidget extends StatelessWidget {
  final DriverStats stats;
  const _ScoreCardWidget({required this.stats});

  @override
  Widget build(BuildContext context) {
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
