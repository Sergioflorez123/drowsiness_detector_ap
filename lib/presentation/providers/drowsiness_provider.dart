import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../core/services/location_service.dart';
import '../../core/services/vision_service.dart';
import '../../data/datasources/remote/activity_log_datasource.dart';
import '../../data/datasources/remote/driving_remote_datasource.dart';
import '../../data/datasources/remote/event_service.dart';
import '../../domain/entities/drowsiness_state.dart';
import 'ai_sensitivity_provider.dart';
import 'alert_provider.dart';
import 'driving_session_id_provider.dart';
import 'emergency_provider.dart';

final drowsinessProvider =
    StateNotifierProvider<DrowsinessController, DrowsinessState>((ref) {
  return DrowsinessController(ref);
});

class DrowsinessSessionSummary {
  final Map<DrowsinessLevel, int> secondsPerLevel;
  final DrowsinessLevel maxLevel;
  final int criticalBursts;

  const DrowsinessSessionSummary({
    required this.secondsPerLevel,
    required this.maxLevel,
    required this.criticalBursts,
  });
}

class DrowsinessController extends StateNotifier<DrowsinessState> {
  DrowsinessController(this.ref)
      : super(const DrowsinessState(
          level: DrowsinessLevel.normal,
          eyeClosureDuration: 0,
        ));

  final Ref ref;
  VisionService? _vision;

  DateTime _lastAccumulateAt = DateTime.now();
  final Map<DrowsinessLevel, int> _secondsPerLevel = {
    for (final l in DrowsinessLevel.values) l: 0,
  };
  DrowsinessLevel _maxLevel = DrowsinessLevel.normal;
  int _criticalBursts = 0;
  DateTime? _lastSampleSent;
  DateTime? _lastLocationEventAt;
  bool _contactAlertSent = false;
  final _location = LocationService();
  final _eventService = EventService();

  void resetSessionTracking() {
    _vision?.dispose();
    _vision = VisionService();
    _lastAccumulateAt = DateTime.now();
    for (final l in DrowsinessLevel.values) {
      _secondsPerLevel[l] = 0;
    }
    _maxLevel = DrowsinessLevel.normal;
    _criticalBursts = 0;
    _lastSampleSent = null;
    _lastLocationEventAt = null;
    _contactAlertSent = false;
  }

  DrowsinessSessionSummary finishSessionSummary() {
    final now = DateTime.now();
    final delta = now.difference(_lastAccumulateAt).inSeconds;
    if (delta > 0) {
      final level = state.level;
      _secondsPerLevel[level] = (_secondsPerLevel[level] ?? 0) + delta;
    }
    _lastAccumulateAt = now;
    return DrowsinessSessionSummary(
      secondsPerLevel: Map<DrowsinessLevel, int>.from(_secondsPerLevel),
      maxLevel: _maxLevel,
      criticalBursts: _criticalBursts,
    );
  }

  Future<void> process(InputImage image) async {
    try {
      await _processFrame(image);
    } catch (e, st) {
      debugPrint('Drowsiness process error: $e\n$st');
    }
  }

  Future<void> _processFrame(InputImage image) async {
    final threshold = ref.read(aiSensitivityProvider);
    final previousLevel = state.level;

    _vision ??= VisionService();
    final result = await _vision!.processImage(
      image,
      eyeOpenThreshold: threshold,
    );

    final now = DateTime.now();
    final delta = now.difference(_lastAccumulateAt).inSeconds;
    if (delta > 0) {
      _secondsPerLevel[previousLevel] =
          (_secondsPerLevel[previousLevel] ?? 0) + delta;
    }
    _lastAccumulateAt = now;

    if (result.level.index > _maxLevel.index) {
      _maxLevel = result.level;
    }

    if (result.level == DrowsinessLevel.critical &&
        previousLevel != DrowsinessLevel.critical) {
      _criticalBursts++;
    }

    state = result;

    await ref.read(alertProvider.notifier).syncWithLevel(result.level);

    final gotWorse = result.level.index > previousLevel.index;
    if (gotWorse && result.level.index >= DrowsinessLevel.drowsy.index) {
      ref.read(emergencyProvider.notifier).trigger(result.level.name);
      unawaited(
        ref.read(activityLogDataSourceProvider).log(
              activityType: ActivityType.drowsinessAlert,
              details: {'level': result.level.name},
            ),
      );
    }

    if (result.level.index >= DrowsinessLevel.tired.index) {
      await _maybeSaveDrowsinessLocation(result.level.name, now);
    }

    if (result.level == DrowsinessLevel.critical) {
      ref.read(emergencyProvider.notifier).startLiveEmergencyTracking();
      if (!_contactAlertSent) {
        _contactAlertSent = true;
        unawaited(
          ref.read(emergencyProvider.notifier).triggerContactAlert(
                severity: 'critical',
                reason: 'Somnolencia critica detectada — conductor no despierta',
              )
        );
      }
    } else {
      ref.read(emergencyProvider.notifier).stopLiveEmergencyTracking();
      _contactAlertSent = false;
      ref.read(whatsAppAlertStatusProvider.notifier).state = null;
    }

    final sessionId = ref.read(drivingSessionIdProvider);
    if (sessionId != null) {
      final now = DateTime.now();
      final last = _lastSampleSent;
      if (last == null ||
          now.difference(last) >= const Duration(seconds: 12)) {
        _lastSampleSent = now;
        await ref.read(drivingRemoteDataSourceProvider).insertSample(
              sessionId: sessionId,
              level: result.level.name,
              eyeClosureSec: result.eyeClosureDuration,
            );
      }
    }
  }

  Future<void> _maybeSaveDrowsinessLocation(String severity, DateTime now) async {
    final last = _lastLocationEventAt;
    if (last != null &&
        now.difference(last) < const Duration(seconds: 18)) {
      return;
    }
    _lastLocationEventAt = now;
    try {
      final pos = await _location.getCurrentFast();
      await _eventService.saveEvent(
        type: 'drowsiness_location',
        lat: pos.latitude,
        lng: pos.longitude,
        severity: severity,
      );
    } catch (_) {}
  }

  void disposeVision() {
    _vision?.dispose();
    _vision = null;
  }
}
