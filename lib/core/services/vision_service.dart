import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/drowsiness_state.dart';

class VisionService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
    ),
  );

  DateTime? _lastClosedTime;
  double _threshold = 0.4;
  bool _thresholdLoaded = false;

  Future<void> _loadThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    _threshold = prefs.getDouble('ai_sensitivity') ?? 0.4;
    _thresholdLoaded = true;
  }

  Future<DrowsinessState> processImage(InputImage image) async {
    if (!_thresholdLoaded) await _loadThreshold();

    final faces = await _detector.processImage(image);

    if (faces.isEmpty) {
      return const DrowsinessState(
        level: DrowsinessLevel.normal,
        eyeClosureDuration: 0,
      );
    }

    final face = faces.first;

    final leftEye = face.leftEyeOpenProbability ?? 1;
    final rightEye = face.rightEyeOpenProbability ?? 1;

    final isClosed = leftEye < _threshold && rightEye < _threshold;

    double duration = 0;

    if (isClosed) {
      _lastClosedTime ??= DateTime.now();
      duration = DateTime.now()
          .difference(_lastClosedTime!)
          .inMilliseconds /
          1000;
    } else {
      _lastClosedTime = null;
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

  void dispose() {
    _detector.close();
  }
}
