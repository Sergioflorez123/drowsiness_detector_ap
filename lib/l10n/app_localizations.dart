import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

<<<<<<< HEAD
  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Eye Alert'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Drive awake. Arrive safe.'**
  String get appTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your safe trip…'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @enterButton.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enterButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @errorLogin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorLogin;

  /// No description provided for @errorRegister.
  ///
  /// In en, this message translates to:
  /// **'Could not create account. Check your data or if the email is already in use.'**
  String get errorRegister;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe driving'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do today?'**
  String get homeSubtitle;

  /// No description provided for @cardDriveTitle.
  ///
  /// In en, this message translates to:
  /// **'Start route'**
  String get cardDriveTitle;

  /// No description provided for @cardDriveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI checks your eyes in real time'**
  String get cardDriveSubtitle;

  /// No description provided for @cardMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Live map'**
  String get cardMapTitle;

  /// No description provided for @cardMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your position and emergency context'**
  String get cardMapSubtitle;

  /// No description provided for @cardStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get cardStatsTitle;

  /// No description provided for @cardStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'History by day and safety score'**
  String get cardStatsSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSecurityAi.
  ///
  /// In en, this message translates to:
  /// **'Safety & AI'**
  String get settingsSecurityAi;

  /// No description provided for @settingsSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Camera sensitivity'**
  String get settingsSensitivity;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change how the app looks'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Use system theme'**
  String get settingsSystemTheme;

  /// No description provided for @settingsSystemThemeSnack.
  ///
  /// In en, this message translates to:
  /// **'Using system theme'**
  String get settingsSystemThemeSnack;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'End session on this device?'**
  String get settingsSignOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver insights'**
  String get statsTitle;

  /// No description provided for @statsSafetyScore.
  ///
  /// In en, this message translates to:
  /// **'Safety score'**
  String get statsSafetyScore;

  /// No description provided for @statsWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts this week ({count})'**
  String statsWeeklyTitle(int count);

  /// No description provided for @statsFootnote.
  ///
  /// In en, this message translates to:
  /// **'{alerts} alerts · {sessions} sessions'**
  String statsFootnote(int alerts, int sessions);

  /// No description provided for @statsDailyOpens.
  ///
  /// In en, this message translates to:
  /// **'App opens by day'**
  String get statsDailyOpens;

  /// No description provided for @statsNoOpens.
  ///
  /// In en, this message translates to:
  /// **'No activity logged yet. Open the app on different days to see this chart.'**
  String get statsNoOpens;

  /// No description provided for @statsPerfExcellent.
  ///
  /// In en, this message translates to:
  /// **'Impressive driving. Keep these habits.'**
  String get statsPerfExcellent;

  /// No description provided for @statsPerfGood.
  ///
  /// In en, this message translates to:
  /// **'Solid performance. Watch fatigue on long trips.'**
  String get statsPerfGood;

  /// No description provided for @statsPerfWatch.
  ///
  /// In en, this message translates to:
  /// **'Several risk signals. Plan breaks.'**
  String get statsPerfWatch;

  /// No description provided for @statsPerfHigh.
  ///
  /// In en, this message translates to:
  /// **'High risk. Rest before driving.'**
  String get statsPerfHigh;

  /// No description provided for @statsNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Use “Start route” and open the app on different days to see trends.'**
  String get statsNoDataBody;

  /// No description provided for @statsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load data'**
  String get statsError;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Live map'**
  String get mapTitle;

  /// No description provided for @mapLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding your position…'**
  String get mapLocating;

  /// No description provided for @mapPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for the map.'**
  String get mapPermission;

  /// No description provided for @mapOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get mapOpenSettings;

  /// No description provided for @hudAwake.
  ///
  /// In en, this message translates to:
  /// **'AWAKE'**
  String get hudAwake;

  /// No description provided for @hudTired.
  ///
  /// In en, this message translates to:
  /// **'TIRED'**
  String get hudTired;

  /// No description provided for @hudAlert.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get hudAlert;

  /// No description provided for @hudDanger.
  ///
  /// In en, this message translates to:
  /// **'DANGER!'**
  String get hudDanger;

  /// No description provided for @hudEyesClosed.
  ///
  /// In en, this message translates to:
  /// **'Eyes closed: {seconds}s'**
  String hudEyesClosed(String seconds);

  /// No description provided for @sensitivityLow.
  ///
  /// In en, this message translates to:
  /// **'Low (fewer alerts)'**
  String get sensitivityLow;

  /// No description provided for @sensitivityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get sensitivityNormal;

  /// No description provided for @sensitivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High (more sensitive)'**
  String get sensitivityHigh;

  /// No description provided for @sensitivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity: {label}'**
  String sensitivityLabel(String label);

  /// No description provided for @validatorEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get validatorEmailEmpty;

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get validatorPasswordEmpty;

  /// No description provided for @validatorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get validatorPasswordShort;

  /// No description provided for @validatorNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validatorNameEmpty;
=======
  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'EyeAlert'**
  String get appName;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {name}!'**
  String welcomeTitle(String name);

  /// No description provided for @dashboardSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de tu descanso y rendimiento:'**
  String get dashboardSummary;

  /// No description provided for @startDriving.
  ///
  /// In es, this message translates to:
  /// **'IR A CONDUCIR'**
  String get startDriving;

  /// No description provided for @currentStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado Actual'**
  String get currentStatus;

  /// No description provided for @weeklyEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos Semanales'**
  String get weeklyEvents;
>>>>>>> d201df58447c89a3bb3601f7fc38a8f3e56b85b0
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
