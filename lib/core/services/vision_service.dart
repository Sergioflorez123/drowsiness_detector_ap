import 'dart:math';

import '../../domain/entities/drowsiness_state.dart';

class VisionService {
  DateTime? lastEyeOpenTime;

  DrowsinessState processFrame() {
    final random = Random();
    final eyeClosed = random.nextBool();

    double duration = 0;

    if (eyeClosed) {
      duration = random.nextDouble() * 3;
    } else {
      lastEyeOpenTime = DateTime.now();
    }

    final level = _classify(duration);

    return DrowsinessState(
      level: level,
      eyeClosureDuration: duration,
    );
  }

  DrowsinessLevel _classify(double duration) {
    if (duration < 0.5) return DrowsinessLevel.normal;
    if (duration < 1.5) return DrowsinessLevel.tired;
    if (duration < 2.5) return DrowsinessLevel.drowsy;
    return DrowsinessLevel.critical;
  }
}

