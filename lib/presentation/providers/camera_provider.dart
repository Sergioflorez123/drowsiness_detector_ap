import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/camera_service.dart';

final cameraProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(service.dispose);
  return service;
});

