import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../presentation/providers/locale_provider.dart';
import '../presentation/providers/theme_provider.dart';
import 'router.dart';

class AppColors {
  static const primary = Color(0xFF0A1F44); // Azul oscuro
  static const secondary = Color(0xFF00BFFF); // Celeste brillante
  static const success = Color(0xFF00C853); // Verde alerta
  static const warning = Color(0xFFFFD600); // Amarillo advertencia
  static const danger = Color(0xFFD50000); // Rojo peligro
  static const background = Color(0xFFF2F4F8); // Gris claro
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const _seedLight = Color(0xFF6366F1);
  static const _seedDark = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'EyeAlert',
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
=======
      routerConfig: appRouter,
      localizationsDelegates: const [
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
<<<<<<< HEAD
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedLight,
          brightness: Brightness.light,
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF06B6D4),
          tertiary: const Color(0xFFEC4899),
=======
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.danger,
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
<<<<<<< HEAD
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
=======
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
<<<<<<< HEAD
        brightness: Brightness.dark,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedDark,
          brightness: Brightness.dark,
          primary: const Color(0xFF22D3EE),
          secondary: const Color(0xFFA78BFA),
          tertiary: const Color(0xFF34D399),
          surface: const Color(0xFF111827),
=======
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          brightness: Brightness.dark,
          primary: AppColors.secondary,
          secondary: AppColors.success,
          error: AppColors.danger,
          surface: const Color(0xFF162A4F),
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xFF111827),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
