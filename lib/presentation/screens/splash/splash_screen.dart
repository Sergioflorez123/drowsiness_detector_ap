import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      context.go(session != null ? '/home' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04122D), Color(0xFF020818)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF0A1A39),
                  border: Border.all(color: const Color(0xFF1EE7FF).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, color: Color(0xFF1EE7FF), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'SYSTEM PROTOCOL ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF6EEBFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 42),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF16D9FF).withOpacity(0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16D9FF).withOpacity(0.22),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFF081731),
                      ),
                      child: const Icon(
                        Icons.remove_red_eye_rounded,
                        size: 72,
                        color: Color(0xFF18DEFF),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 10,
                      child: LinearProgressIndicator(
                        value: 0.82,
                        minHeight: 4,
                        backgroundColor: const Color(0xFF1A2A47),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1EE7FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'EYE\nALERT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1DE6FF),
                  fontSize: 44,
                  height: 0.92,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ADVANCED THREAT RECOGNITION INTERFACE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5D7C9A),
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 60),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    LinearProgressIndicator(
                      value: 0.66,
                      minHeight: 3,
                      backgroundColor: Color(0xFF1A2A47),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1EE7FF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'BIOMETRIC STREAM 66%',
                      style: TextStyle(
                        color: Color(0xFF6EEBFF),
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
