import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../../widgets/eye_alert_brand_header.dart';
=======
import 'dart:async';
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _textIndex = 0;
  final List<String> _loadingTexts = [
    'Iniciando detección...',
    'Escaneando rostro...',
    'Monitoreando somnolencia...',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    Future.delayed(const Duration(milliseconds: 1800), () {
=======
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _textIndex = (_textIndex + 1) % _loadingTexts.length;
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      context.go(session != null ? '/home' : '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.secondary,
              scheme.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.apply(
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      ),
                  colorScheme: scheme.copyWith(
                    secondary: Colors.white.withOpacity(0.92),
                  ),
                ),
                child: const EyeAlertBrandHeader(),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.splashLoading,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
=======
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1F44), // Azul oscuro
              Color(0xFF007BFF), // Azul medio
              Color(0xFF00BFFF), // Celeste brillante
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * 3.14159,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BFFF)),
                          strokeWidth: 4,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      );
                    },
                  ),
                ),
                const Icon(
                  Icons.remove_red_eye_rounded,
                  size: 64,
                  color: Colors.white,
                ),
                const Positioned(
                  bottom: 30,
                  right: 30,
                  child: Icon(
                    Icons.camera_alt,
                    size: 24,
                    color: Color(0xFF00C853), // Verifica estado de alerta (punto verde)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'EyeAlert',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _loadingTexts[_textIndex],
                key: ValueKey<int>(_textIndex),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
        ),
      ),
    );
  }
}
