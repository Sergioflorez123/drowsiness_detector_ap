import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../presentation/providers/locale_provider.dart';
import '../presentation/providers/theme_provider.dart';
import 'eye_alert_colors.dart';
import 'router.dart';

class AppColors {
  static const primary = EyeAlertColors.primary;
  static const background = EyeAlertColors.background;
  static const cardSurface = EyeAlertColors.cardSurface;
  static const levelNormal = EyeAlertColors.levelNormal;
  static const levelTired = EyeAlertColors.levelTired;
  static const levelDrowsy = EyeAlertColors.levelDrowsy;
  static const levelCritical = EyeAlertColors.levelCritical;
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const _seedLight = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'EyeAlert',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFEAF4FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedLight,
          brightness: Brightness.light,
          primary: const Color(0xFF0B4C80),
          secondary: const Color(0xFF0A89B5),
          tertiary: const Color(0xFF00A4D6),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
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
          fillColor: const Color(0xFFDCECF8),
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
        brightness: Brightness.dark,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: EyeAlertColors.textSecondary,
          displayColor: EyeAlertColors.textPrimary,
        ),
        scaffoldBackgroundColor: EyeAlertColors.background,
        colorScheme: const ColorScheme.dark(
          primary: EyeAlertColors.primary,
          secondary: EyeAlertColors.levelNormal,
          surface: EyeAlertColors.cardSurface,
          onSurface: EyeAlertColors.textPrimary,
          error: EyeAlertColors.levelCritical,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: EyeAlertColors.textPrimary,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: EyeAlertColors.cardSurface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: EyeAlertColors.cardSurface,
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
