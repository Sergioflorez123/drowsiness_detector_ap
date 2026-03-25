import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await controller?.initialize();
  }

  Future<void> startStream(Function(InputImage) onFrame) async {
    await controller?.startImageStream((image) {
      try {
        final inputImage = _convert(image);
        if (inputImage != null) onFrame(inputImage);
      } catch (e) {
        // Ignorar fotogramas defectuosos
      }
    });
  }

  Future<void> stopStream() async {
    if (controller?.value.isStreamingImages == true) {
      await controller?.stopImageStream();
    }
  }

  InputImage? _convert(CameraImage image) {
    if (controller == null) return null;

    final sensorOrientation = controller!.description.sensorOrientation;
    InputImageRotation rotation = InputImageRotation.rotation0deg;
    switch (sensorOrientation) {
      case 90: rotation = InputImageRotation.rotation90deg; break;
      case 180: rotation = InputImageRotation.rotation180deg; break;
      case 270: rotation = InputImageRotation.rotation270deg; break;
    }

    final format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Widget buildPreview() {
    if (!isInitialized) return const ColoredBox(color: Colors.black);
    
    // Devolvemos el tamaño exacto proporcionado por la cámara
    // Para no crear estiramientos antes de que el FittedBox lo procese.
    final size = controller!.value.previewSize!;
    return SizedBox(
      width: size.height,  
      height: size.width,
      child: CameraPreview(controller!),
    );
  }

  void dispose() {
    controller?.dispose();
  }
}
