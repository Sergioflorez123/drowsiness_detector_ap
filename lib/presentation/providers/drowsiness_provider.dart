import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/services/vision_service.dart';
import '../../domain/entities/drowsiness_state.dart';
import 'alert_provider.dart';
import 'emergency_provider.dart';

final drowsinessProvider =
    StateNotifierProvider<DrowsinessController, DrowsinessState>((ref) {
  return DrowsinessController(ref);
});

class DrowsinessController extends StateNotifier<DrowsinessState> {
  final Ref ref;
  final VisionService _vision = VisionService();

  DrowsinessController(this.ref)
      : super(const DrowsinessState(
          level: DrowsinessLevel.normal,
          eyeClosureDuration: 0,
        ));

  Future<void> process(InputImage image) async {
    final result = await _vision.processImage(image);
    state = result;

    if (result.level == DrowsinessLevel.critical) {
      ref.read(alertProvider.notifier).trigger();
      ref.read(emergencyProvider.notifier).trigger('critical');
    }
  }

  void disposeVision() {
    _vision.dispose();
  }
}
