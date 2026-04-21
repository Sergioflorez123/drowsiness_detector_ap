// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Eye Alert';

  @override
  String get appTagline => 'Conduce despierto. Llega seguro.';

  @override
  String get splashLoading => 'Preparando tu viaje seguro…';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get fullNameLabel => 'Nombre completo';

  @override
  String get enterButton => 'Entrar';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get noAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get haveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get errorLogin => 'Correo o contraseña incorrectos.';

  @override
  String get errorRegister =>
      'No se pudo crear la cuenta. Revisa tus datos o si el correo ya existe.';

  @override
  String get homeTitle => 'Conducción segura';

  @override
  String homeGreeting(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get homeSubtitle => '¿Qué quieres hacer hoy?';

  @override
  String get cardDriveTitle => 'Iniciar ruta';

  @override
  String get cardDriveSubtitle => 'La IA revisa tus ojos en tiempo real';

  @override
  String get cardMapTitle => 'Mapa en vivo';

  @override
  String get cardMapSubtitle => 'Tu posición y contexto de emergencia';

  @override
  String get cardStatsTitle => 'Estadísticas';

  @override
  String get cardStatsSubtitle => 'Historial por día y puntaje de seguridad';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSecurityAi => 'Seguridad e IA';

  @override
  String get settingsSensitivity => 'Sensibilidad de cámara';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsDarkModeSubtitle => 'Cambia el aspecto de la app';

  @override
  String get settingsSystemTheme => 'Usar tema del sistema';

  @override
  String get settingsSystemThemeSnack => 'Usando el tema del sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsSignOutConfirm => '¿Cerrar sesión en este dispositivo?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get statsTitle => 'Análisis del conductor';

  @override
  String get statsSafetyScore => 'Puntaje de seguridad';

  @override
  String statsWeeklyTitle(int count) {
    return 'Alertas esta semana ($count)';
  }

  @override
  String statsFootnote(int alerts, int sessions) {
    return '$alerts alertas · $sessions sesiones de conducción';
  }

  @override
  String get statsDailyOpens => 'Aperturas de la app por día';

  @override
  String get statsNoOpens =>
      'Aún no hay actividad. Abre la app en distintos días para ver esta gráfica.';

  @override
  String get statsPerfExcellent =>
      'Conducción impecable. Mantén estos hábitos.';

  @override
  String get statsPerfGood =>
      'Buen desempeño. Vigila la fatiga en trayectos largos.';

  @override
  String get statsPerfWatch =>
      'Se observaron varios riesgos. Planifica descansos.';

  @override
  String get statsPerfHigh =>
      'Riesgo alto. Prioriza descanso antes de conducir.';

  @override
  String get statsNoDataBody =>
      'Sin datos aún. Usa “Iniciar ruta” y abre la app en varios días para ver tendencias.';

  @override
  String get statsError => 'No se pudo cargar la información';

  @override
  String get mapTitle => 'Mapa en vivo';

  @override
  String get mapLocating => 'Buscando tu posición…';

  @override
  String get mapPermission => 'Se necesita permiso de ubicación para el mapa.';

  @override
  String get mapOpenSettings => 'Abrir ajustes';

  @override
  String get hudAwake => 'DESPIERTO';

  @override
  String get hudTired => 'CANSADO';

  @override
  String get hudAlert => 'ALERTA';

  @override
  String get hudDanger => '¡PELIGRO!';

  @override
  String hudEyesClosed(String seconds) {
    return 'Ojos cerrados: ${seconds}s';
  }

  @override
  String get sensitivityLow => 'Baja (menos alertas)';

  @override
  String get sensitivityNormal => 'Normal';

  @override
  String get sensitivityHigh => 'Alta (más sensible)';

  @override
  String sensitivityLabel(String label) {
    return 'Sensibilidad: $label';
  }

  @override
  String get validatorEmailEmpty => 'El correo no puede estar vacío';

  @override
  String get validatorEmailInvalid => 'Ingresa un correo válido';

  @override
  String get validatorPasswordEmpty => 'La contraseña no puede estar vacía';

  @override
  String get validatorPasswordShort => 'Al menos 6 caracteres';

  @override
  String get validatorNameEmpty => 'El nombre es obligatorio';
}
