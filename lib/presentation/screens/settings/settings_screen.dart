import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _sensitivity = 0.4;

  @override
  void initState() {
    super.initState();
    _loadSensitivity();
  }

  Future<void> _loadSensitivity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sensitivity = prefs.getDouble('ai_sensitivity') ?? 0.4;
    });
  }

  Future<void> _saveSensitivity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ai_sensitivity', value);
    setState(() {
      _sensitivity = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? 'Usuario';
    final email = user?.email ?? '';

    bool isDark = themeMode == ThemeMode.dark;
    if (themeMode == ThemeMode.system) {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    String sensitivityLabel = 'Normal (0.4)';
    if (_sensitivity <= 0.2) sensitivityLabel = 'Baja (Difícil que pite)';
    else if (_sensitivity >= 0.6) sensitivityLabel = 'Alta (Pita al mínimo sueño)';

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            accountName: Text(
              name,
              style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Seguridad e IA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            title: const Text('Sensibilidad de Cámara (Detector)'),
            subtitle: Text(sensitivityLabel),
          ),
          Slider(
            value: _sensitivity,
            min: 0.1,
            max: 0.8,
            divisions: 7,
            label: _sensitivity.toStringAsFixed(1),
            onChanged: _saveSensitivity,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Apariencia', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
        ],
      ),
    );
  }
}
