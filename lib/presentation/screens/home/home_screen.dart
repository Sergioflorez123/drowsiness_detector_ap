import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';

import '../../../data/datasources/remote/driving_remote_datasource.dart';
import '../../../data/datasources/remote/event_service.dart';
import '../../providers/stats_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _riskLabel(int score) {
    if (score >= 90) return 'Bajo';
    if (score >= 70) return 'Moderado';
    if (score >= 50) return 'Alto';
    return 'Crítico';
  }

  Color _riskColor(ColorScheme scheme, int score) {
    if (score >= 90) return const Color(0xFF00E5FF);
    if (score >= 70) return const Color(0xFF00B8D4);
    if (score >= 50) return Colors.orange;
    return scheme.error;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(drivingRemoteDataSourceProvider).logAppOpenedToday();
      await EventService().syncOfflineEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Usuario';
    final scheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF040B1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF9EEFFF),
        scrolledUnderElevation: 0,
        title: Text(l.homeTitle),
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
              l.homeGreeting(name),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l.homeSubtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF26D9FF),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 22),
            statsAsync.when(
              loading: () => const _CyberContainer(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (err, stack) => _CyberContainer(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'No se pudo cargar el dashboard: $err',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              data: (stats) {
                final riskColor = _riskColor(scheme, stats.safetyScore);
                final riskLabel = _riskLabel(stats.safetyScore);
                return _CyberContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dashboard de somnolencia',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF81EDFF),
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: riskColor.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: riskColor.withOpacity(0.6),
                                ),
                              ),
                              child: Text(
                                riskLabel,
                                style: TextStyle(
                                  color: riskColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A1838), Color(0xFF071126)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: const Color(0xFF1FD4FF).withOpacity(0.28),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 160,
                                height: 160,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: CircularProgressIndicator(
                                        value: stats.safetyScore / 100,
                                        strokeWidth: 11,
                                        backgroundColor: const Color(
                                          0xFF1A2A47,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          riskColor,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${stats.safetyScore}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          riskLabel.toUpperCase(),
                                          style: TextStyle(
                                            color: riskColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'DRIVER ALERTNESS',
                                style: TextStyle(
                                  color: Color(0xFF6ECFE7),
                                  fontSize: 11,
                                  letterSpacing: 1.3,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricChip(
                                label: 'Eventos 7 días',
                                value: '${stats.totalEvents}',
                                icon: Icons.warning_amber_rounded,
                                color: const Color(0xFF00C9FF),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricChip(
                                label: 'Sesiones 7 días',
                                value: '${stats.totalSessions}',
                                icon: Icons.route_rounded,
                                color: const Color(0xFF65F1FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Niveles de somnolencia',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF8BEDFF),
                              ),
                        ),
                        const SizedBox(height: 8),
                        const _DrowsinessLevelRow(
                          label: 'Normal',
                          description: 'Conducción estable y alerta.',
                          color: Color(0xFF00E5FF),
                        ),
                        const _DrowsinessLevelRow(
                          label: 'Cansado',
                          description: 'Primeras señales de fatiga.',
                          color: Color(0xFF2EBDFF),
                        ),
                        const _DrowsinessLevelRow(
                          label: 'Somnoliento',
                          description: 'Riesgo alto, tomar una pausa.',
                          color: Color(0xFFFFA726),
                        ),
                        const _DrowsinessLevelRow(
                          label: 'Crítico',
                          description: 'Peligro inmediato, detenerse.',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Accesos rápidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8BEDFF),
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SideActionButton(
                  title: l.cardDriveTitle,
                  icon: Icons.directions_car_filled_rounded,
                  accent: const Color(0xFF00D2FF),
                  onTap: () => context.push('/driving'),
                ),
                _SideActionButton(
                  title: l.cardMapTitle,
                  icon: Icons.map_rounded,
                  accent: const Color(0xFF5CE7FF),
                  onTap: () => context.push('/map'),
                ),
                _SideActionButton(
                  title: l.cardStatsTitle,
                  icon: Icons.insights_rounded,
                  accent: const Color(0xFF7AF6FF),
                  onTap: () => context.push('/stats'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _CyberContainer(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF4DDCFF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.statsNoDataBody,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFD3F6FF),
                            ),
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

class _CyberContainer extends StatelessWidget {
  const _CyberContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF091530), Color(0xFF071022)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF1FD4FF).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CCFF).withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SideActionButton extends StatelessWidget {
  const _SideActionButton({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 52) / 2;
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0B1A39), Color(0xFF0A1632)],
            ),
            border: Border.all(color: accent.withOpacity(0.65)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9BC9D6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrowsinessLevelRow extends StatelessWidget {
  const _DrowsinessLevelRow({
    required this.label,
    required this.description,
    required this.color,
  });

  final String label;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFD1F7FF)),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
