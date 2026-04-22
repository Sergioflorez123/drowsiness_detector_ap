import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../../providers/ai_sensitivity_provider.dart';
import '../../providers/emergency_contact_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _sensitivityCaption(AppLocalizations l, double v) {
    if (v <= 0.2) return l.sensitivityLow;
    if (v >= 0.6) return l.sensitivityHigh;
    return l.sensitivityNormal;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final themeMode = ref.watch(themeProvider);
    final sensitivity = ref.watch(aiSensitivityProvider);
    final emergencyContact = ref.watch(emergencyContactProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Usuario';
    final email = user?.email ?? '';

    var isDark = themeMode == ThemeMode.dark;
    if (themeMode == ThemeMode.system) {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    Future<void> confirmSignOut() async {
      final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l.settingsSignOut),
              content: Text(l.settingsSignOutConfirm),
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

    Future<void> editEmergencyContact() async {
      var name = emergencyContact.name;
      var phone = emergencyContact.phone;
      final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(isEs ? 'Contacto de emergencia' : 'Emergency contact'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(
                      labelText: isEs ? 'Nombre' : 'Name',
                    ),
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: isEs ? 'Telefono' : 'Phone',
                    ),
                    onChanged: (v) => phone = v,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(isEs ? 'Guardar' : 'Save'),
                ),
              ],
            ),
          ) ??
          false;
      if (!ok) return;
      await ref.read(emergencyContactProvider.notifier).save(
            name: name,
            phone: phone,
          );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            accountName: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              email,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l.settingsSecurityAi,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          ListTile(
            title: Text(l.settingsSensitivity),
            subtitle: Text(
              l.sensitivityLabel(_sensitivityCaption(l, sensitivity)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone_rounded),
            title: Text(
              isEs ? 'Contacto de emergencia' : 'Emergency contact',
            ),
            subtitle: Text(
              emergencyContact.isValid
                  ? '${emergencyContact.name} - ${emergencyContact.phone}'
                  : (isEs
                      ? 'Configura nombre y telefono'
                      : 'Set name and phone'),
            ),
            onTap: editEmergencyContact,
          ),
          Slider(
            value: sensitivity,
            min: 0.1,
            max: 0.8,
            divisions: 7,
            label: sensitivity.toStringAsFixed(1),
            onChanged: (v) =>
                ref.read(aiSensitivityProvider.notifier).setSensitivity(v),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l.settingsAppearance,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          SwitchListTile(
            title: Text(l.settingsDarkMode),
            subtitle: Text(l.settingsDarkModeSubtitle),
            value: isDark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_android_rounded),
            title: Text(l.settingsSystemTheme),
            onTap: () async {
              await ref.read(themeProvider.notifier).useSystemTheme();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.settingsSystemThemeSnack)),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
            title: Text(l.settingsSignOut),
            onTap: confirmSignOut,
          ),
        ],
      ),
    );
  }
}
