import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../core/services/vision_service.dart';
import '../../data/datasources/remote/driving_remote_datasource.dart';
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
  final VisionService _vision = VisionService();

  DateTime _lastAccumulateAt = DateTime.now();
  final Map<DrowsinessLevel, int> _secondsPerLevel = {
    for (final l in DrowsinessLevel.values) l: 0,
  };
  DrowsinessLevel _maxLevel = DrowsinessLevel.normal;
  int _criticalBursts = 0;
  DateTime? _lastSampleSent;

  void resetSessionTracking() {
    _lastAccumulateAt = DateTime.now();
    for (final l in DrowsinessLevel.values) {
      _secondsPerLevel[l] = 0;
    }
    _maxLevel = DrowsinessLevel.normal;
    _criticalBursts = 0;
    _lastSampleSent = null;
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
    final threshold = ref.read(aiSensitivityProvider);
    final previousLevel = state.level;

    final result = await _vision.processImage(
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

    if (result.level == DrowsinessLevel.critical) {
      ref.read(alertProvider.notifier).trigger();
      ref.read(emergencyProvider.notifier).trigger('critical');
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

  void disposeVision() {
    _vision.dispose();
  }
}
