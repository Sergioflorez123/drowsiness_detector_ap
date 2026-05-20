import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../../providers/activity_log_provider.dart';
import '../../providers/session_history_provider.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/session_history_map.dart';
import '../../../domain/entities/driving_session_record.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  String _activityLabel(String type, bool isEs) {
    switch (type) {
      case 'app_open':
        return isEs ? 'Apertura de la app' : 'App opened';
      case 'driving_start':
        return isEs ? 'Inicio de ruta' : 'Drive started';
      case 'driving_end':
        return isEs ? 'Fin de ruta' : 'Drive ended';
      case 'drowsiness_alert':
        return isEs ? 'Alerta de somnolencia' : 'Drowsiness alert';
      case 'emergency_contact_saved':
        return isEs ? 'Contacto de emergencia guardado' : 'Emergency contact saved';
      case 'sensitivity_changed':
        return isEs ? 'Sensibilidad cambiada' : 'Sensitivity changed';
      default:
        return type;
    }
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'app_open':
        return Icons.home_rounded;
      case 'driving_start':
        return Icons.play_circle_outline_rounded;
      case 'driving_end':
        return Icons.stop_circle_outlined;
      case 'drowsiness_alert':
        return Icons.warning_amber_rounded;
      case 'emergency_contact_saved':
        return Icons.contact_phone_rounded;
      case 'sensitivity_changed':
        return Icons.tune_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String _perfMessage(AppLocalizations l, DriverStats s) {
    if (s.isEmpty) return l.statsNoDataBody;
    if (s.safetyScore >= 90) return l.statsPerfExcellent;
    if (s.safetyScore >= 70) return l.statsPerfGood;
    if (s.safetyScore >= 50) return l.statsPerfWatch;
    return l.statsPerfHigh;
  }

  String _levelLabel(String level, bool isEs) {
    switch (level) {
      case 'critical':
        return isEs ? 'Crítico' : 'Critical';
      case 'drowsy':
        return isEs ? 'Somnoliento' : 'Drowsy';
      case 'tired':
        return isEs ? 'Cansado' : 'Tired';
      default:
        return isEs ? 'Normal' : 'Normal';
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'critical':
        return const Color(0xFFFF5252);
      case 'drowsy':
        return const Color(0xFFFF9800);
      case 'tired':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF1EE7FF);
    }
  }

  String _formatDuration(int? seconds, bool isEs) {
    if (seconds == null || seconds <= 0) {
      return isEs ? 'En curso' : 'In progress';
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return isEs ? '${m} min ${s}s' : '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final theme = Theme.of(context);
    final statsAsync = ref.watch(statsProvider);
    final historyAsync = ref.watch(sessionHistoryProvider);
    final activityAsync = ref.watch(recentActivityProvider);
    final dateFmt = DateFormat(isEs ? 'EEEE d MMM, HH:mm' : 'EEE MMM d, HH:mm');
    final hourFmt = DateFormat(isEs ? 'd MMM · HH:mm' : 'MMM d · HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(l.statsTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsProvider);
          ref.invalidate(sessionHistoryProvider);
          ref.invalidate(recentActivityProvider);
          await Future.wait([
            ref.read(statsProvider.future),
            ref.read(sessionHistoryProvider.future),
            ref.read(recentActivityProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            statsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('${l.statsError}\n$err'),
              data: (stats) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        l.statsSafetyScore,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${stats.safetyScore}%',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: stats.safetyScore > 80
                              ? theme.colorScheme.primary
                              : stats.safetyScore > 50
                                  ? Colors.orange
                                  : theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _perfMessage(l, stats),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.statsFootnote(stats.totalEvents, stats.totalSessions),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEs ? 'Actividad por día y hora' : 'Activity by day and hour',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            activityAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (entries) {
                if (entries.isEmpty) {
                  return Text(
                    isEs
                        ? 'Sin movimientos registrados aún.'
                        : 'No activity logged yet.',
                    style: theme.textTheme.bodySmall,
                  );
                }
                final shown = entries.take(12).toList();
                return Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = shown[i];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          _activityIcon(e.type),
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        title: Text(
                          _activityLabel(e.type, isEs),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(hourFmt.format(e.recordedAt)),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              isEs ? 'Historial de rutas' : 'Trip history',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEs
                  ? 'Cada inicio de sesión, ordenado del más reciente al anterior.'
                  : 'Each drive session, newest first.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 14),
            historyAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('${l.statsError}\n$err'),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        isEs
                            ? 'Aún no hay rutas guardadas. Usa "Iniciar ruta" para registrar tu primera sesión.'
                            : 'No trips yet. Tap "Start drive" to record your first session.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < sessions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      _SessionHistoryCard(
                        session: sessions[i],
                        dateLabel: dateFmt.format(sessions[i].startedAt),
                        durationLabel:
                            _formatDuration(sessions[i].durationSeconds, isEs),
                        levelLabel: _levelLabel(sessions[i].maxLevel, isEs),
                        levelColor: _levelColor(sessions[i].maxLevel),
                        isEs: isEs,
                        isLatest: i == 0,
                      ),
                    ],
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

class _SessionHistoryCard extends StatefulWidget {
  const _SessionHistoryCard({
    required this.session,
    required this.dateLabel,
    required this.durationLabel,
    required this.levelLabel,
    required this.levelColor,
    required this.isEs,
    required this.isLatest,
  });

  final DrivingSessionRecord session;
  final String dateLabel;
  final String durationLabel;
  final String levelLabel;
  final Color levelColor;
  final bool isEs;
  final bool isLatest;

  @override
  State<_SessionHistoryCard> createState() => _SessionHistoryCardState();
}

class _SessionHistoryCardState extends State<_SessionHistoryCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isLatest;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isLatest)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              widget.isEs ? 'Última sesión' : 'Latest session',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        Text(
                          widget.dateLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isEs
                              ? 'Duración: ${widget.durationLabel} · ${widget.session.drowsinessPoints.length} puntos en mapa'
                              : 'Duration: ${widget.durationLabel} · ${widget.session.drowsinessPoints.length} map points',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.levelColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      widget.levelLabel,
                      style: TextStyle(
                        color: widget.levelColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: theme.hintColor,
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SessionHistoryMap(
                  points: widget.session.drowsinessPoints,
                  height: 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _StatPill(
                      label: widget.isEs ? 'Normal' : 'Normal',
                      value: '${widget.session.secNormal}s',
                      color: const Color(0xFF1EE7FF),
                    ),
                    _StatPill(
                      label: widget.isEs ? 'Cansado' : 'Tired',
                      value: '${widget.session.secTired}s',
                      color: const Color(0xFFFFC107),
                    ),
                    _StatPill(
                      label: widget.isEs ? 'Somnol.' : 'Drowsy',
                      value: '${widget.session.secDrowsy}s',
                      color: const Color(0xFFFF9800),
                    ),
                    _StatPill(
                      label: widget.isEs ? 'Crítico' : 'Critical',
                      value: '${widget.session.secCritical}s',
                      color: const Color(0xFFFF5252),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
