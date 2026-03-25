import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? controller;

  bool get isInitialized => controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller?.initialize();
  }

  Future<void> startStream(Function(InputImage) onFrame) async {
    await controller?.startImageStream((image) {
      final inputImage = _convert(image);
      onFrame(inputImage);
    });
  }

  InputImage _convert(CameraImage image) {
    final bytes = image.planes.first.bytes;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: const Size(480, 640),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Widget buildPreview() {
    if (!isInitialized) return const ColoredBox(color: Colors.black);
    return CameraPreview(controller!);
  }

  void dispose() {
    controller?.dispose();
  }
}
