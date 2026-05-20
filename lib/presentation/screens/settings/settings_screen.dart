import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../../../app/eye_alert_colors.dart';
import '../../../data/datasources/remote/activity_log_datasource.dart';
import '../../providers/ai_sensitivity_provider.dart';
import '../../providers/emergency_contact_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  bool _savingContact = false;
  bool _contactHydrated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateContactFields());
  }

  void _hydrateContactFields() {
    if (!mounted || _contactHydrated) return;
    final c = ref.read(emergencyContactProvider);
    if (c.name.isNotEmpty || c.phone.isNotEmpty) {
      _contactNameController.text = c.name;
      _contactPhoneController.text = c.phone;
      _contactHydrated = true;
    }
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  String _sensitivityCaption(AppLocalizations l, double v) {
    if (v <= 0.2) return l.sensitivityLow;
    if (v >= 0.6) return l.sensitivityHigh;
    return l.sensitivityNormal;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final themeMode = ref.watch(themeProvider);
    final sensitivity = ref.watch(aiSensitivityProvider);
    final locale = ref.watch(localeProvider);
    final localeCtrl = ref.read(localeProvider.notifier);
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.userMetadata?['name'] as String? ?? 'Usuario';
    final email = user?.email ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    ref.listen<EmergencyContact>(emergencyContactProvider, (_, next) {
      if (!_contactHydrated && (next.name.isNotEmpty || next.phone.isNotEmpty)) {
        _contactNameController.text = next.name;
        _contactPhoneController.text = next.phone;
        _contactHydrated = true;
      }
    });

    var isDark = themeMode == ThemeMode.dark;
    if (themeMode == ThemeMode.system) {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    final sensLabel = _sensitivityCaption(l, sensitivity);

    Future<void> confirmSignOut() async {
      final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: EyeAlertColors.cardSurface,
              title: Text(
                l.settingsSignOut,
                style: const TextStyle(color: EyeAlertColors.textPrimary),
              ),
              content: Text(
                l.settingsSignOutConfirm,
                style: const TextStyle(color: EyeAlertColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l.settingsSignOut),
                ),
              ],
            ),
          ) ??
          false;
      if (!ok || !context.mounted) return;
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      context.go('/login');
    }

    Future<void> saveEmergencyContact() async {
      setState(() => _savingContact = true);
      final ok = await ref.read(emergencyContactProvider.notifier).save(
            name: _contactNameController.text,
            phone: _contactPhoneController.text,
          );
      if (!context.mounted) return;
      setState(() => _savingContact = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (isEs
                    ? 'Contacto guardado en Supabase'
                    : 'Contact saved to Supabase')
                : (isEs
                    ? 'Guardado localmente. Revisa conexión.'
                    : 'Saved locally. Check connection.'),
          ),
        ),
      );
    }

    final primaryColor = isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80);
    final textPrimary = isDark ? EyeAlertColors.textPrimary : const Color(0xFF0F172A);
    final textSecondary = isDark ? EyeAlertColors.textSecondary : const Color(0xFF475569);
    final bgColor = isDark ? EyeAlertColors.background : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l.settingsTitle,
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _HeaderLangPill(
              isSpanish: locale.languageCode == 'es',
              onTap: () {
                if (locale.languageCode == 'es') {
                  localeCtrl.setEnglish();
                } else {
                  localeCtrl.setSpanish();
                }
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _ProfileHeader(
            initial: initial,
            name: displayName,
            email: email,
          ),
          const SizedBox(height: 28),
          _SectionLabel(
            isEs ? 'SEGURIDAD E IA' : 'SECURITY & AI',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.settingsSensitivity,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: isEs ? 'Sensibilidad: ' : 'Sensitivity: ',
                                ),
                                TextSpan(
                                  text: sensLabel,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.photo_camera_outlined,
                      color: primaryColor,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: primaryColor.withValues(alpha: 0.35),
                    inactiveTrackColor: isDark ? EyeAlertColors.borderSubtle : const Color(0xFFCBD5E1),
                    thumbColor: EyeAlertColors.primary,
                    overlayColor: EyeAlertColors.primary.withValues(alpha: 0.15),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    tickMarkShape: const RoundSliderTickMarkShape(),
                    activeTickMarkColor: EyeAlertColors.textSecondary,
                    inactiveTickMarkColor: EyeAlertColors.borderSubtle,
                  ),
                  child: Slider(
                    value: sensitivity,
                    min: 0.1,
                    max: 0.8,
                    divisions: 7,
                    onChanged: (v) async {
                      await ref
                          .read(aiSensitivityProvider.notifier)
                          .setSensitivity(v);
                      await ref.read(activityLogDataSourceProvider).log(
                            activityType: ActivityType.sensitivityChanged,
                            details: {'value': v},
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(
            isEs ? 'CONTACTO DE EMERGENCIA' : 'EMERGENCY CONTACT',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: isEs
                            ? 'Esta información se guarda de forma segura en '
                            : 'This information is securely stored in ',
                      ),
                      TextSpan(
                        text: 'Supabase',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: isEs
                            ? ' para el envío de alertas críticas por WhatsApp.'
                            : ' for critical WhatsApp alerts.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _DarkTextField(
                  controller: _contactNameController,
                  hint: isEs ? 'Nombre completo' : 'Full name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _DarkTextField(
                  controller: _contactPhoneController,
                  hint: isEs
                      ? 'Teléfono (con código de país)'
                      : 'Phone (with country code)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: isDark ? EyeAlertColors.background : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _savingContact ? null : saveEmergencyContact,
                    icon: _savingContact
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: EyeAlertColors.background,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_outlined, size: 22),
                    label: Text(
                      isEs ? 'Guardar contacto' : 'Save contact',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(isEs ? 'APARIENCIA' : 'APPEARANCE'),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              children: [
                _AppearanceRow(
                  icon: Icons.dark_mode_outlined,
                  title: l.settingsDarkMode,
                  subtitle: l.settingsDarkModeSubtitle,
                  onTap: () {
                    ref.read(themeProvider.notifier).toggleTheme(!isDark);
                  },
                  trailing: Switch(
                    value: isDark,
                    activeColor: isDark ? EyeAlertColors.background : Colors.white,
                    activeTrackColor: primaryColor,
                    inactiveThumbColor: isDark ? EyeAlertColors.textSecondary : const Color(0xFF64748B),
                    inactiveTrackColor: isDark ? EyeAlertColors.borderSubtle : const Color(0xFFE2E8F0),
                    onChanged: (v) {
                      ref.read(themeProvider.notifier).toggleTheme(v);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(
                    height: 1,
                    color: EyeAlertColors.borderSubtle.withValues(alpha: 0.6),
                  ),
                ),
                _AppearanceRow(
                  icon: Icons.smartphone_outlined,
                  title: l.settingsSystemTheme,
                  subtitle: null,
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: EyeAlertColors.textSecondary,
                  ),
                  onTap: () async {
                    await ref.read(themeProvider.notifier).useSystemTheme();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.settingsSystemThemeSnack)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Material(
            color: isDark ? const Color(0xFF1A0A0E) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: confirmSignOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: EyeAlertColors.levelCritical.withValues(alpha: 0.9),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l.settingsSignOut,
                      style: TextStyle(
                        color: EyeAlertColors.levelCritical.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'NEURAL MONITORING PANEL · V2.0.4',
              style: TextStyle(
                color: textSecondary,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLangPill extends StatelessWidget {
  const _HeaderLangPill({
    required this.isSpanish,
    required this.onTap,
  });

  final bool isSpanish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? EyeAlertColors.primary.withValues(alpha: 0.5)
                : const Color(0xFF0B4C80).withValues(alpha: 0.3),
          ),
          color: Theme.of(context).brightness == Brightness.dark 
              ? EyeAlertColors.cardSurface
              : Colors.white,
        ),
        child: Text(
          isSpanish ? 'ES' : 'EN',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? EyeAlertColors.primary 
                : const Color(0xFF0B4C80),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initial,
    required this.name,
    required this.email,
  });

  final String initial;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? const [Color(0xFF0A3D5C), Color(0xFF062840)]
                      : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (Theme.of(context).brightness == Brightness.dark 
                        ? EyeAlertColors.primary 
                        : const Color(0xFF0B4C80)).withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: (Theme.of(context).brightness == Brightness.dark 
                      ? EyeAlertColors.primary 
                      : const Color(0xFF0B4C80)).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? EyeAlertColors.textPrimary 
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? EyeAlertColors.primary 
                      : const Color(0xFF0B4C80),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? EyeAlertColors.background 
                        : Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? EyeAlertColors.background 
                      : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? EyeAlertColors.textPrimary 
                : const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? EyeAlertColors.textSecondary 
                : const Color(0xFF475569),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        color: isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: isDark 
          ? EyeAlertColors.cardDecoration(radius: 18)
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF0B4C80).withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B4C80).withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
      child: child,
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? EyeAlertColors.textPrimary : const Color(0xFF0F172A);
    final textSecondary = isDark ? EyeAlertColors.textSecondary : const Color(0xFF475569);
    final primaryColor = isDark ? EyeAlertColors.primary : const Color(0xFF0B4C80);
    final bgColor = isDark ? EyeAlertColors.background : const Color(0xFFF1F5F9);
    final borderColor = isDark ? EyeAlertColors.borderSubtle.withValues(alpha: 0.8) : const Color(0xFFE2E8F0);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: textSecondary, size: 22),
        filled: true,
        fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1),
        ),
      ),
    );
  }
}

class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? EyeAlertColors.primary : const Color(0xFF0B4C80), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? EyeAlertColors.textPrimary : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? EyeAlertColors.textSecondary : const Color(0xFF475569),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
