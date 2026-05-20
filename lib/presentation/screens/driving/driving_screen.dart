import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/services/camera_service.dart';
import '../../../data/datasources/remote/activity_log_datasource.dart';
import '../../../data/datasources/remote/driving_remote_datasource.dart';
import '../../../domain/entities/drowsiness_state.dart';
import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../../providers/alert_provider.dart';
import '../../providers/camera_provider.dart';
import '../../providers/driving_session_id_provider.dart';
import '../../providers/drowsiness_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/session_history_provider.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/driving_mini_map.dart';

class DrivingScreen extends ConsumerStatefulWidget {
  const DrivingScreen({super.key});

  @override
  ConsumerState<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends ConsumerState<DrivingScreen> {
  bool _ready = false;
  bool _teardownDone = false;
  DateTime? _sessionStart;
  String? _localSessionId;
  bool _isProcessingFrame = false;

  late final AlertController _alertCtrl;
  late final CameraService _cameraService;
  late final DrivingRemoteDataSource _drivingDs;
  late final ActivityLogDataSource _activityDs;
  late final DrowsinessController _drowsinessCtrl;
  late final StateController<String?> _sessionIdCtrl;

  @override
  void initState() {
    super.initState();
    _alertCtrl = ref.read(alertProvider.notifier);
    _cameraService = ref.read(cameraProvider);
    _drivingDs = ref.read(drivingRemoteDataSourceProvider);
    _activityDs = ref.read(activityLogDataSourceProvider);
    _drowsinessCtrl = ref.read(drowsinessProvider.notifier);
    _sessionIdCtrl = ref.read(drivingSessionIdProvider.notifier);
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      await WakelockPlus.enable();

      // Solicitar permisos de cámara y localización de forma secuencial y limpia
      final cameraStatus = await Permission.camera.request();
      final locationStatus = await Permission.locationWhenInUse.request();

      if (!locationStatus.isGranted) {
        debugPrint('Location permission denied: maps and real-time alerts will not include live coordinates.');
      }

      if (!cameraStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requiere permiso de cámara para la detección de somnolencia.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          context.pop();
        }
        return;
      }

      await _cameraService.initialize();

      if (!_cameraService.isInitialized) {
        throw Exception('No se pudo inicializar la cámara frontal.');
      }

      _isProcessingFrame = false;
      // Iniciar el stream de la cámara de inmediato para que el conductor vea su rostro sin esperas
      await _cameraService.startStream(
        (image) async {
          if (!mounted) return;
          try {
            _isProcessingFrame = true;
            await _drowsinessCtrl.process(image);
          } finally {
            _isProcessingFrame = false;
          }
        },
        isBusy: () => _isProcessingFrame,
      );

      _drowsinessCtrl.resetSessionTracking();
      _sessionStart = DateTime.now();

      if (!mounted) return;
      setState(() => _ready = true);

      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50);
      }

      // Iniciar sesión remota de Supabase en segundo plano con timeout
      unawaited(() async {
        try {
          final sessionId = await _drivingDs.startDrivingSession().timeout(
            const Duration(seconds: 6),
          );
          _localSessionId = sessionId;
          _sessionIdCtrl.state = sessionId;
          if (sessionId != null) {
            await _activityDs.log(
              activityType: ActivityType.drivingStart,
              details: {'session_id': sessionId},
            ).timeout(const Duration(seconds: 4));
          }
        } catch (e) {
          debugPrint('Supabase driving session background start error: $e');
        }
      }());
    } catch (e) {
      debugPrint('Driving init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo iniciar la ruta: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _tearDownSession() async {
    if (_teardownDone) return;
    _teardownDone = true;

    await _alertCtrl.stopAlert();

    try {
      await _cameraService.stopStream();
    } catch (e) {
      debugPrint('Camera stop: $e');
    }

    final sessionId = _localSessionId ?? _sessionIdCtrl.state;
    _sessionIdCtrl.state = null;
    _localSessionId = null;

    if (sessionId != null && _sessionStart != null) {
      try {
        final summary = _drowsinessCtrl.finishSessionSummary();
        final duration = DateTime.now()
            .difference(_sessionStart!)
            .inSeconds
            .clamp(0, 86400);
        await _drivingDs.endDrivingSession(
          sessionId: sessionId,
          durationSeconds: duration,
          maxLevel: summary.maxLevel.name,
          secNormal: summary.secondsPerLevel[DrowsinessLevel.normal] ?? 0,
          secTired: summary.secondsPerLevel[DrowsinessLevel.tired] ?? 0,
          secDrowsy: summary.secondsPerLevel[DrowsinessLevel.drowsy] ?? 0,
          secCritical: summary.secondsPerLevel[DrowsinessLevel.critical] ?? 0,
          criticalEvents: summary.criticalBursts,
        );
        await _activityDs.log(
          activityType: ActivityType.drivingEnd,
          details: {
            'session_id': sessionId,
            'duration_seconds': duration,
            'max_level': summary.maxLevel.name,
          },
        );
      } catch (e) {
        debugPrint('End session error: $e');
      }
    }

    _drowsinessCtrl.disposeVision();

    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  Future<void> _exitDriving() async {
    await _tearDownSession();
    if (!mounted) return;
    ref.invalidate(sessionHistoryProvider);
    ref.invalidate(statsProvider);
    context.pop();
  }

  @override
  void dispose() {
    unawaited(_tearDownSession());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drowsinessProvider);
    final cameraService = ref.watch(cameraProvider);
    final l = AppLocalizations.of(context)!;
    final wAlertStatus = ref.watch(whatsAppAlertStatusProvider);

    final isCritical = state.level == DrowsinessLevel.critical;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _ready && cameraService.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: cameraService.buildPreview(),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.45)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              border: Border.all(
                color: isCritical ? Colors.redAccent : Colors.transparent,
                width: isCritical ? 12 : 0,
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: _exitDriving,
            ),
          ),
          if (_ready)
            const Positioned(
              top: 52,
              right: 12,
              child: DrivingMiniMap(),
            ),
          if (wAlertStatus != null)
            Positioned(
              top: 140,
              left: 20,
              right: 20,
              child: _WhatsAppSOSCard(
                status: wAlertStatus, 
                isEs: Localizations.localeOf(context).languageCode == 'es'
              ),
            ),
          _HUDOverlay(state: state, l: l),
        ],
      ),
    );
  }
}

class _HUDOverlay extends StatelessWidget {
  const _HUDOverlay({required this.state, required this.l});

  final DrowsinessState state;
  final AppLocalizations l;

  Color get color {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return const Color(0xFF00E676);
      case DrowsinessLevel.tired:
        return const Color(0xFFFFC107);
      case DrowsinessLevel.drowsy:
        return const Color(0xFFFF9800);
      case DrowsinessLevel.critical:
        return const Color(0xFFFF3D00);
    }
  }

  String get text {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return l.hudAwake;
      case DrowsinessLevel.tired:
        return l.hudTired;
      case DrowsinessLevel.drowsy:
        return l.hudAlert;
      case DrowsinessLevel.critical:
        return l.hudDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.5,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.75), blurRadius: 28),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: color.withValues(alpha: 0.45), width: 2),
              ),
              child: Text(
                l.hudEyesClosed(state.eyeClosureDuration.toStringAsFixed(1)),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppSOSCard extends StatelessWidget {
  const _WhatsAppSOSCard({required this.status, required this.isEs});
  final String status;
  final bool isEs;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String text;
    
    switch (status) {
      case 'sending':
        icon = Icons.satellite_alt_rounded;
        color = Colors.blueAccent;
        text = isEs ? 'OBTENIENDO GPS Y PREPARANDO ALERTA...' : 'FETCHING GPS & PREPARING ALERT...';
        break;
      case 'sent':
        icon = Icons.check_circle_rounded;
        color = Colors.greenAccent;
        text = isEs ? '¡ALERTA ENVIADA A WHATSAPP!' : 'ALERT SENT TO WHATSAPP!';
        break;
      case 'invalid_contact':
        icon = Icons.warning_rounded;
        color = Colors.orangeAccent;
        text = isEs ? 'SIN CONTACTO SOS REGISTRADO' : 'NO SOS CONTACT REGISTERED';
        break;
      default:
        icon = Icons.error_rounded;
        color = Colors.redAccent;
        text = isEs ? 'ERROR AL ENVIAR ALERTA SOS' : 'FAILED TO SEND SOS ALERT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          if (status == 'sending')
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
            )
          else
            Icon(icon, color: color, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
