// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'EyeAlert';

  @override
  String welcomeTitle(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get dashboardSummary => 'Resumen de tu descanso y rendimiento:';

  @override
  String get startDriving => 'IR A CONDUCIR';

  @override
  String get currentStatus => 'Estado Actual';

  @override
  String get weeklyEvents => 'Eventos Semanales';
}
