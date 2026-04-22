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
                            const Icon(
                              Icons.remove_red_eye_rounded,
                              color: Color(0xFF81EDFF),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EYE ALERT',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF81EDFF),
                                    letterSpacing: 1.1,
                                  ),
                            ),
                            const Spacer(),
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
                                'NEURAL SYNC',
                                style: TextStyle(
                                  color: riskColor.withOpacity(0.95),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'BIOMETRIC STATUS\nDRIVER\nALERTNESS',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: const Color(0xFF9DD5E3),
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFF122B44),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF1FD4FF,
                                        ).withOpacity(0.4),
                                      ),
                                    ),
                                    child: const Text(
                                      'ACTIVE\nSCAN',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF76E9FF),
                                        fontSize: 10,
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
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF081731),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF1FD4FF,
                                    ).withOpacity(0.22),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFF0A1430),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF1FD4FF,
                                        ).withOpacity(0.52),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF1FD4FF,
                                          ).withOpacity(0.15),
                                          blurRadius: 24,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${stats.safetyScore}%',
                                          style: const TextStyle(
                                            color: Color(0xFF1EE7FF),
                                            fontSize: 42,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          riskLabel.toUpperCase(),
                                          style: TextStyle(
                                            color: riskColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CyberContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'ALERTNESS LEVELS',
                                  style: TextStyle(
                                    color: Color(0xFF8DD5E9),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    fontSize: 11,
                                  ),
                                ),
                                SizedBox(height: 10),
                                _DrowsinessGrid(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricChip(
                                label: 'RECENT EVENTS (7D)',
                                value: '${stats.totalEvents}',
                                icon: Icons.warning_amber_rounded,
                                color: const Color(0xFFFFA26B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricChip(
                                label: 'TOTAL SESSIONS',
                                value: '${stats.totalSessions}',
                                icon: Icons.route_rounded,
                                color: const Color(0xFF65F1FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _ActivityPanel(),
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
            _CyberContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomQuickButton(
                        label: 'Mapa',
                        icon: Icons.map_outlined,
                        onTap: () => context.push('/map'),
                      ),
                    ),
                    Expanded(
                      child: _BottomQuickButton(
                        label: 'Iniciar',
                        icon: Icons.directions_car_filled_rounded,
                        active: true,
                        onTap: () => context.push('/driving'),
                      ),
                    ),
                    Expanded(
                      child: _BottomQuickButton(
                        label: 'Historial',
                        icon: Icons.history_rounded,
                        onTap: () => context.push('/stats'),
                      ),
                    ),
                    Expanded(
                      child: _BottomQuickButton(
                        label: 'Config',
                        icon: Icons.settings_rounded,
                        onTap: () => context.push('/settings'),
                      ),
                    ),
                  ],
                ),
              ),
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

class _BottomQuickButton extends StatelessWidget {
  const _BottomQuickButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1EE7FF) : const Color(0xFF5D7C9A);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrowsinessGrid extends StatelessWidget {
  const _DrowsinessGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LevelMini(
                title: 'NORMAL',
                subtitle: 'optimal response',
                color: Color(0xFF1EE7FF),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _LevelMini(
                title: 'TIRED',
                subtitle: 'increased blink duration',
                color: Color(0xFF6C88A5),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _LevelMini(
                title: 'DROWSY',
                subtitle: 'micro-sleeps risk detected',
                color: Color(0xFFFFA726),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _LevelMini(
                title: 'CRITICAL',
                subtitle: 'immediate intervention',
                color: Color(0xFFFF5252),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelMini extends StatelessWidget {
  const _LevelMini({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE8F9FF),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6E92AE),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel();

  @override
  Widget build(BuildContext context) {
    return _CyberContainer(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'NEURAL ACTIVITY',
                  style: TextStyle(
                    color: Color(0xFF8DD5E9),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontSize: 11,
                  ),
                ),
                Spacer(),
                Text(
                  'OCULAR TRACKING: ON',
                  style: TextStyle(
                    color: Color(0xFF22DCFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF07142D),
                border: Border.all(
                  color: const Color(0xFF1FD4FF).withOpacity(0.2),
                ),
              ),
              child: const Center(
                child: Text(
                  '~ ~ ~ ~ ~ ~ ~ ~',
                  style: TextStyle(
                    color: Color(0xFF29E4FF),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniStat(label: 'EYE FRQ', value: '2.4Hz'),
                _MiniStat(label: 'PUPIL DL', value: '4.2mm'),
                _MiniStat(label: 'BLINK SPD', value: '120ms'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6E92AE),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2DE8FF),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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

