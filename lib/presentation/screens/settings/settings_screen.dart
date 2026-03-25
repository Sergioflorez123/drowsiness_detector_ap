import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Usuario';
    final email = user?.email ?? '';

    bool isDark = themeMode == ThemeMode.dark;
    if (themeMode == ThemeMode.system) {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            accountName: Text(
              name,
              style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color),
            ),
            accountEmail: Text(
              email,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambiar la apariencia de la aplicación'),
            value: isDark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme(value);
            },
          ),
          ListTile(
            title: const Text('Usar tema del sistema'),
            trailing: const Icon(Icons.phone_android),
            onTap: () {
              ref.read(themeProvider.notifier).useSystemTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cambiado al tema del sistema')),
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Acerca de'),
            subtitle: Text('Detección Segura v1.0'),
          ),
        ],
      ),
    );
  }
}
