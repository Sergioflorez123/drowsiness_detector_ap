import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../../providers/ai_sensitivity_provider.dart';
import '../../providers/locale_provider.dart';
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
    final themeMode = ref.watch(themeProvider);
    final sensitivity = ref.watch(aiSensitivityProvider);
    final locale = ref.watch(localeProvider);
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              l.settingsLanguage,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          RadioListTile<String>(
            title: Text(l.settingsLanguageSpanish),
            value: 'es',
            groupValue: locale.languageCode,
            onChanged: (_) => ref.read(localeProvider.notifier).setSpanish(),
          ),
          RadioListTile<String>(
            title: Text(l.settingsLanguageEnglish),
            value: 'en',
            groupValue: locale.languageCode,
            onChanged: (_) => ref.read(localeProvider.notifier).setEnglish(),
          ),
          const Divider(height: 1),
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
