import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/vision_service.dart';
import '../../domain/entities/drowsiness_state.dart';

final drowsinessProvider =
    StateNotifierProvider<DrowsinessController, DrowsinessState>((ref) {
  return DrowsinessController();
});

class DrowsinessController extends StateNotifier<DrowsinessState> {
  final VisionService _visionService = VisionService();
  Timer? _timer;

  DrowsinessController()
      : super(
          const DrowsinessState(
            level: DrowsinessLevel.normal,
            eyeClosureDuration: 0,
          ),
        );

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      state = _visionService.processFrame();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

