import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/datasources/remote/driving_remote_datasource.dart';
import '../../../data/datasources/remote/event_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/stats_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _riskLabel(int score, bool isEs) {
    if (score >= 90) return isEs ? 'Vigilante' : 'Vigilant';
    if (score >= 70) return isEs ? 'Estable' : 'Stable';
    if (score >= 50) return isEs ? 'Riesgo' : 'Risk';
    return isEs ? 'Critico' : 'Critical';
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
    final locale = ref.watch(localeProvider);
    final localeCtrl = ref.read(localeProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final themeCtrl = ref.read(themeProvider.notifier);
    final isEs = locale.languageCode == 'es';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Usuario';
    final scheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF040B1C) : const Color(0xFFEFF7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? const Color(0xFF9EEFFF) : const Color(0xFF00314D),
        scrolledUnderElevation: 0,
        title: Text(l.homeTitle),
        actions: [
          _LangSegment(
            isSpanish: isEs,
            onSpanish: localeCtrl.setSpanish,
            onEnglish: localeCtrl.setEnglish,
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: isEs ? 'Modo oscuro' : 'Dark mode',
            icon: Icon(
              (themeMode == ThemeMode.dark) ||
                      (themeMode == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark)
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            onPressed: () {
              final isCurrentlyDark =
                  (themeMode == ThemeMode.dark) ||
                      (themeMode == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark);
              themeCtrl.toggleTheme(!isCurrentlyDark);
            },
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
                    color: isDark ? Colors.white : const Color(0xFF032B44),
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              isEs ? 'Panel de monitoreo neural' : 'Neural monitoring panel',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDark ? const Color(0xFF26D9FF) : const Color(0xFF007EA8),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 18),
            statsAsync.when(
              loading: () => _CyberContainer(
                isDark: isDark,
                child: const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (err, stack) => _CyberContainer(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Dashboard error: $err',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF003A52),
                    ),
                  ),
                ),
              ),
              data: (stats) {
                final riskColor = _riskColor(scheme, stats.safetyScore);
                final riskLabel = _riskLabel(stats.safetyScore, isEs);
                return _CyberContainer(
                  isDark: isDark,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_rounded,
                              color: isDark
                                  ? const Color(0xFF81EDFF)
                                  : const Color(0xFF006D93),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EYE ALERT',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? const Color(0xFF81EDFF)
                                        : const Color(0xFF006D93),
                                    letterSpacing: 1.1,
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
                            gradient: LinearGradient(
                              colors: isDark
                                  ? const [Color(0xFF0A1838), Color(0xFF071126)]
                                  : const [Color(0xFFE1F2FF), Color(0xFFD4EBFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: (isDark
                                      ? const Color(0xFF1FD4FF)
                                      : const Color(0xFF0095CA))
                                  .withOpacity(0.28),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isEs
                                          ? 'ESTADO BIOMETRICO\nALERTA\nCONDUCTOR'
                                          : 'BIOMETRIC STATUS\nDRIVER\nALERTNESS',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: isDark
                                                ? const Color(0xFF9DD5E3)
                                                : const Color(0xFF005E82),
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
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
                                  color:
                                      isDark ? const Color(0xFF081731) : const Color(0xFFCCE9FC),
                                  border: Border.all(
                                    color: (isDark
                                            ? const Color(0xFF1FD4FF)
                                            : const Color(0xFF007EA8))
                                        .withOpacity(0.22),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isDark
                                          ? const Color(0xFF0A1430)
                                          : const Color(0xFFEAF7FF),
                                      border: Border.all(
                                        color: (isDark
                                                ? const Color(0xFF1FD4FF)
                                                : const Color(0xFF0087B6))
                                            .withOpacity(0.52),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${stats.safetyScore}%',
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF1EE7FF)
                                                : const Color(0xFF006A8F),
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
                          isDark: isDark,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEs ? 'NIVELES DE ALERTA' : 'ALERTNESS LEVELS',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF8DD5E9)
                                        : const Color(0xFF006E95),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _DrowsinessGrid(isEs: isEs, isDark: isDark),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricChip(
                                label: isEs
                                    ? 'EVENTOS RECIENTES (7D)'
                                    : 'RECENT EVENTS (7D)',
                                value: '${stats.totalEvents}',
                                icon: Icons.warning_amber_rounded,
                                color: const Color(0xFFFFA26B),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricChip(
                                label: isEs ? 'SESIONES TOTALES' : 'TOTAL SESSIONS',
                                value: '${stats.totalSessions}',
                                icon: Icons.route_rounded,
                                color: const Color(0xFF65F1FF),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              isEs ? 'Accesos rapidos' : 'Quick access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color:
                        isDark ? const Color(0xFF8BEDFF) : const Color(0xFF006A8F),
                  ),
            ),
            const SizedBox(height: 12),
            _CyberContainer(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomQuickButton(
                        label: isEs ? 'Mapa' : 'Map',
                        icon: Icons.map_outlined,
                        onTap: () => context.push('/map'),
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _BottomQuickButton(
                        label: isEs ? 'Iniciar' : 'Drive',
                        icon: Icons.directions_car_filled_rounded,
                        active: true,
                        onTap: () => context.push('/driving'),
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _BottomQuickButton(
                        label: isEs ? 'Historial' : 'History',
                        icon: Icons.history_rounded,
                        onTap: () => context.push('/stats'),
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _BottomQuickButton(
                        label: isEs ? 'Ajustes' : 'Settings',
                        icon: Icons.settings_rounded,
                        onTap: () => context.push('/settings'),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _CyberContainer(
              isDark: isDark,
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
                              color: isDark
                                  ? const Color(0xFFD3F6FF)
                                  : const Color(0xFF0A4A63),
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

class _LangToggle extends StatelessWidget {
  const _LangToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1EE7FF).withOpacity(0.45)),
          color: selected ? const Color(0xFF1EE7FF) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF03293C) : Theme.of(context).hintColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LangSegment extends StatelessWidget {
  const _LangSegment({
    required this.isSpanish,
    required this.onSpanish,
    required this.onEnglish,
  });

  final bool isSpanish;
  final VoidCallback onSpanish;
  final VoidCallback onEnglish;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1EE7FF).withOpacity(0.35)),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0A1A36)
            : const Color(0xFFDDF1FF),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangPill(
            label: 'ES',
            active: isSpanish,
            onTap: onSpanish,
          ),
          _LangPill(
            label: 'EN',
            active: !isSpanish,
            onTap: onEnglish,
          ),
        ],
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: active ? const Color(0xFF1EE7FF) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF03293C) : Theme.of(context).hintColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CyberContainer extends StatelessWidget {
  const _CyberContainer({required this.child, this.isDark = true});

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF091530), Color(0xFF071022)]
              : const [Color(0xFFE6F4FF), Color(0xFFD7EEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: (isDark ? const Color(0xFF1FD4FF) : const Color(0xFF008DBD))
              .withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF00CCFF) : const Color(0xFF00A4D6))
                .withOpacity(0.12),
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
    this.isDark = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (isDark ? const Color(0xFF1EE7FF) : const Color(0xFF006A8F))
        : (isDark ? const Color(0xFF5D7C9A) : const Color(0xFF5F87A1));
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
  const _DrowsinessGrid({required this.isEs, required this.isDark});

  final bool isEs;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LevelMini(
                title: isEs ? 'NORMAL' : 'NORMAL',
                subtitle: isEs ? 'respuesta optima' : 'optimal response',
                color: const Color(0xFF1EE7FF),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LevelMini(
                title: isEs ? 'CANSADO' : 'TIRED',
                subtitle: isEs
                    ? 'parpadeo mas prolongado'
                    : 'increased blink duration',
                color: const Color(0xFF6C88A5),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _LevelMini(
                title: isEs ? 'SOMNOLIENTO' : 'DROWSY',
                subtitle: isEs
                    ? 'riesgo de microsueno detectado'
                    : 'micro-sleeps risk detected',
                color: const Color(0xFFFFA726),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LevelMini(
                title: isEs ? 'CRITICO' : 'CRITICAL',
                subtitle: isEs
                    ? 'intervencion inmediata'
                    : 'immediate intervention',
                color: const Color(0xFFFF5252),
                isDark: isDark,
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
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;

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
                style: TextStyle(
                  color: isDark ? const Color(0xFFE8F9FF) : const Color(0xFF003A52),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? const Color(0xFF6E92AE) : const Color(0xFF4E7690),
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


class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF003A52),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF9BC9D6) : const Color(0xFF2C6780),
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

