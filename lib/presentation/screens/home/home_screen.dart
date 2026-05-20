import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/datasources/remote/activity_log_datasource.dart';
import '../../../data/datasources/remote/driving_remote_datasource.dart';
import '../../../data/datasources/remote/event_service.dart';
import '../../../app/eye_alert_colors.dart';
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
    if (score >= 90) return isEs ? 'VIGILANTE' : 'VIGILANT';
    if (score >= 70) return isEs ? 'ESTABLE' : 'STABLE';
    if (score >= 50) return isEs ? 'RIESGO' : 'RISK';
    return isEs ? 'CRITICO' : 'CRITICAL';
  }

  Color _riskColor(int score, bool isDark) {
    if (score >= 90) return isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80);
    if (score >= 70) return isDark ? EyeAlertColors.levelNormal : const Color(0xFF0A89B5);
    if (score >= 50) return isDark ? EyeAlertColors.levelDrowsy : const Color(0xFFD97706);
    return isDark ? EyeAlertColors.levelCritical : const Color(0xFFDC2626);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(drivingRemoteDataSourceProvider).logAppOpenedToday();
      await ref.read(activityLogDataSourceProvider).log(
            activityType: ActivityType.appOpen,
          );
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
    final statsAsync = ref.watch(statsProvider);

    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final useNeuralTheme = isDark;

    return Scaffold(
      backgroundColor:
          useNeuralTheme ? EyeAlertColors.background : const Color(0xFFEFF7FF),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor:
            useNeuralTheme ? EyeAlertColors.background : const Color(0xFFEFF7FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor:
            useNeuralTheme ? EyeAlertColors.textPrimary : const Color(0xFF00314D),
        title: Text(
          l.homeTitle,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: useNeuralTheme
                ? EyeAlertColors.textPrimary
                : const Color(0xFF00314D),
          ),
        ),
        actions: [
          _LangSegment(
            isSpanish: isEs,
            onSpanish: localeCtrl.setSpanish,
            onEnglish: localeCtrl.setEnglish,
          ),
          IconButton(
            tooltip: isEs ? 'Modo oscuro' : 'Dark mode',
            icon: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: EyeAlertColors.textSecondary,
              size: 22,
            ),
            onPressed: () => themeCtrl.toggleTheme(!isDarkMode),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.homeGreeting(name),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: useNeuralTheme
                    ? EyeAlertColors.textPrimary
                    : const Color(0xFF032B44),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isEs ? 'Panel de monitoreo neural' : 'Neural monitoring panel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: useNeuralTheme
                    ? EyeAlertColors.primary
                    : const Color(0xFF007EA8),
              ),
            ),
            const SizedBox(height: 22),
            statsAsync.when(
              loading: () => const _SurfaceCard(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: EyeAlertColors.primary,
                    ),
                  ),
                ),
              ),
              error: (err, _) => _SurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Dashboard error: $err',
                    style: const TextStyle(color: EyeAlertColors.textPrimary),
                  ),
                ),
              ),
              data: (stats) => _EyeAlertDashboardCard(
                isEs: isEs,
                score: stats.safetyScore,
                riskLabel: _riskLabel(stats.safetyScore, isEs),
                riskColor: _riskColor(stats.safetyScore, isDark),
                eventsCount: stats.totalEvents,
                tripsCount: stats.totalSessions,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isEs ? 'Accesos rapidos' : 'Quick access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: useNeuralTheme
                    ? EyeAlertColors.textPrimary
                    : const Color(0xFF00314D),
              ),
            ),
            const SizedBox(height: 14),
            _QuickAccessBar(
              isEs: isEs,
              onDrive: () => context.push('/driving'),
              onHistory: () => context.push('/stats'),
              onSettings: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta principal EYE ALERT — igual al mockup.
class _EyeAlertDashboardCard extends StatelessWidget {
  const _EyeAlertDashboardCard({
    required this.isEs,
    required this.score,
    required this.riskLabel,
    required this.riskColor,
    required this.eventsCount,
    required this.tripsCount,
  });

  final bool isEs;
  final int score;
  final String riskLabel;
  final Color riskColor;
  final int eventsCount;
  final int tripsCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80);
    final secondaryText = isDark ? EyeAlertColors.textSecondary : const Color(0xFF475569);

    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.remove_red_eye_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'EYE ALERT',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isEs
                  ? 'Estado biométrico del conductor'
                  : 'Driver biometric status',
              style: TextStyle(
                color: secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                    color: score >= 90 ? primaryColor : riskColor,
                    shadows: score >= 90 && isDark ? EyeAlertColors.primaryGlow : null,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: riskColor,
                      shadows: score >= 90 && isDark ? EyeAlertColors.primaryGlow : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              isEs ? 'NIVELES DE ALERTA' : 'ALERTNESS LEVELS',
              style: TextStyle(
                color: secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 14),
            _AlertLevelsGrid(isEs: isEs),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MiniStatTile(
                    icon: Icons.warning_amber_rounded,
                    iconColor: isDark ? EyeAlertColors.levelDrowsy : const Color(0xFFD97706),
                    value: '$eventsCount',
                    label: isEs ? 'Eventos (7 días)' : 'Events (7 days)',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatTile(
                    icon: Icons.route_rounded,
                    iconColor: primaryColor,
                    value: '$tripsCount',
                    label: isEs ? 'Rutas' : 'Trips',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: isDark
          ? EyeAlertColors.cardDecoration(radius: 22)
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF0B4C80).withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B4C80).withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
      child: child,
    );
  }
}

class _AlertLevelsGrid extends StatelessWidget {
  const _AlertLevelsGrid({required this.isEs});

  final bool isEs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AlertLevelCell(
                dotColor: EyeAlertColors.levelNormal,
                title: 'NORMAL',
                subtitle: isEs ? 'respuesta óptima' : 'optimal response',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AlertLevelCell(
                dotColor: EyeAlertColors.levelTired,
                title: isEs ? 'CANSADO' : 'TIRED',
                subtitle: isEs
                    ? 'parpadeo más prolongado'
                    : 'longer blinking',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AlertLevelCell(
                dotColor: EyeAlertColors.levelDrowsy,
                title: isEs ? 'SOMNOLIENTO' : 'DROWSY',
                subtitle: isEs
                    ? 'riesgo de microsueño'
                    : 'microsleep risk',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AlertLevelCell(
                dotColor: EyeAlertColors.levelCritical,
                title: isEs ? 'CRÍTICO' : 'CRITICAL',
                subtitle: isEs
                    ? 'intervención inmediata'
                    : 'immediate action',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AlertLevelCell extends StatelessWidget {
  const _AlertLevelCell({
    required this.dotColor,
    required this.title,
    required this.subtitle,
  });

  final Color dotColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? EyeAlertColors.textPrimary : const Color(0xFF0F172A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? EyeAlertColors.textSecondary : const Color(0xFF475569),
                  fontSize: 10,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  const _MiniStatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? EyeAlertColors.background : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? EyeAlertColors.textPrimary : const Color(0xFF0F172A),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? EyeAlertColors.textSecondary : const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
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

class _QuickAccessBar extends StatelessWidget {
  const _QuickAccessBar({
    required this.isEs,
    required this.onDrive,
    required this.onHistory,
    required this.onSettings,
  });

  final bool isEs;
  final VoidCallback onDrive;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _QuickAccessItem(
                  label: isEs ? 'Iniciar' : 'Drive',
                  icon: Icons.directions_car_filled_rounded,
                  active: true,
                  onTap: onDrive,
                ),
              ),
              _QuickDivider(),
              Expanded(
                child: _QuickAccessItem(
                  label: isEs ? 'Historial' : 'History',
                  icon: Icons.history_rounded,
                  onTap: onHistory,
                ),
              ),
              _QuickDivider(),
              Expanded(
                child: _QuickAccessItem(
                  label: isEs ? 'Ajustes' : 'Settings',
                  icon: Icons.settings_rounded,
                  onTap: onSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDark 
          ? EyeAlertColors.borderSubtle.withValues(alpha: 0.8)
          : const Color(0xFFE2E8F0),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  const _QuickAccessItem({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80);
    final color = active 
        ? primaryColor 
        : (isDark ? EyeAlertColors.navInactive : const Color(0xFF64748B));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active)
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 14,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: primaryColor, size: 26),
                )
              else
                SizedBox(
                  height: 48,
                  child: Icon(icon, color: color, size: 26),
                ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80);
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? EyeAlertColors.background : const Color(0xFFF1F5F9),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangPill(label: 'ES', active: isSpanish, onTap: onSpanish),
          _LangPill(label: 'EN', active: !isSpanish, onTap: onEnglish),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80);
    final activeText = isDark ? EyeAlertColors.background : Colors.white;
    final inactiveText = isDark ? EyeAlertColors.textSecondary : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? activeBg : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }
}
