// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EyeAlert';

  @override
  String welcomeTitle(String name) {
    return 'Hello, $name!';
  }

  @override
  String get dashboardSummary => 'Summary of your rest and performance:';

  @override
  String get startDriving => 'START DRIVING';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get weeklyEvents => 'Weekly Events';
}
