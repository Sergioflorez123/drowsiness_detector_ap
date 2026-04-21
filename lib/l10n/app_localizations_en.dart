// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
<<<<<<< HEAD
  String get appTitle => 'Eye Alert';

  @override
  String get appTagline => 'Drive awake. Arrive safe.';

  @override
  String get splashLoading => 'Preparing your safe trip…';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get enterButton => 'Enter';

  @override
  String get registerButton => 'Register';

  @override
  String get noAccount => 'No account? Register';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get errorLogin => 'Incorrect email or password.';

  @override
  String get errorRegister =>
      'Could not create account. Check your data or if the email is already in use.';

  @override
  String get homeTitle => 'Safe driving';

  @override
  String homeGreeting(String name) {
=======
  String get appName => 'EyeAlert';

  @override
  String welcomeTitle(String name) {
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
    return 'Hello, $name!';
  }

  @override
<<<<<<< HEAD
  String get homeSubtitle => 'What do you want to do today?';

  @override
  String get cardDriveTitle => 'Start route';

  @override
  String get cardDriveSubtitle => 'AI checks your eyes in real time';

  @override
  String get cardMapTitle => 'Live map';

  @override
  String get cardMapSubtitle => 'Your position and emergency context';

  @override
  String get cardStatsTitle => 'Statistics';

  @override
  String get cardStatsSubtitle => 'History by day and safety score';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSecurityAi => 'Safety & AI';

  @override
  String get settingsSensitivity => 'Camera sensitivity';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsDarkModeSubtitle => 'Change how the app looks';

  @override
  String get settingsSystemTheme => 'Use system theme';

  @override
  String get settingsSystemThemeSnack => 'Using system theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirm => 'End session on this device?';

  @override
  String get cancel => 'Cancel';

  @override
  String get statsTitle => 'Driver insights';

  @override
  String get statsSafetyScore => 'Safety score';

  @override
  String statsWeeklyTitle(int count) {
    return 'Alerts this week ($count)';
  }

  @override
  String statsFootnote(int alerts, int sessions) {
    return '$alerts alerts · $sessions sessions';
  }

  @override
  String get statsDailyOpens => 'App opens by day';

  @override
  String get statsNoOpens =>
      'No activity logged yet. Open the app on different days to see this chart.';

  @override
  String get statsPerfExcellent => 'Impressive driving. Keep these habits.';

  @override
  String get statsPerfGood => 'Solid performance. Watch fatigue on long trips.';

  @override
  String get statsPerfWatch => 'Several risk signals. Plan breaks.';

  @override
  String get statsPerfHigh => 'High risk. Rest before driving.';

  @override
  String get statsNoDataBody =>
      'No data yet. Use “Start route” and open the app on different days to see trends.';

  @override
  String get statsError => 'Could not load data';

  @override
  String get mapTitle => 'Live map';

  @override
  String get mapLocating => 'Finding your position…';

  @override
  String get mapPermission => 'Location permission is required for the map.';

  @override
  String get mapOpenSettings => 'Open settings';

  @override
  String get hudAwake => 'AWAKE';

  @override
  String get hudTired => 'TIRED';

  @override
  String get hudAlert => 'WARNING';

  @override
  String get hudDanger => 'DANGER!';

  @override
  String hudEyesClosed(String seconds) {
    return 'Eyes closed: ${seconds}s';
  }

  @override
  String get sensitivityLow => 'Low (fewer alerts)';

  @override
  String get sensitivityNormal => 'Normal';

  @override
  String get sensitivityHigh => 'High (more sensitive)';

  @override
  String sensitivityLabel(String label) {
    return 'Sensitivity: $label';
  }

  @override
  String get validatorEmailEmpty => 'Email cannot be empty';

  @override
  String get validatorEmailInvalid => 'Enter a valid email';

  @override
  String get validatorPasswordEmpty => 'Password cannot be empty';

  @override
  String get validatorPasswordShort => 'At least 6 characters';

  @override
  String get validatorNameEmpty => 'Name is required';
=======
  String get dashboardSummary => 'Summary of your rest and performance:';

  @override
  String get startDriving => 'START DRIVING';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get weeklyEvents => 'Weekly Events';
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
}
