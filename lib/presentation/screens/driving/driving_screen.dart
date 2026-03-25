import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../domain/entities/drowsiness_state.dart';
import '../../providers/camera_provider.dart';
import '../../providers/drowsiness_provider.dart';

class DrivingScreen extends ConsumerStatefulWidget {
  const DrivingScreen({super.key});

  @override
  ConsumerState<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends ConsumerState<DrivingScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cameraService = ref.read(cameraProvider);
    await cameraService.initialize();
    
    await cameraService.startStream((image) {
      if (!mounted) return;
      ref.read(drowsinessProvider.notifier).process(image);
    });

    if (!mounted) return;
    setState(() => _ready = true);
    
    // Slight haptic feedback on start
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  void dispose() {
    ref.read(drowsinessProvider.notifier).disposeVision();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drowsinessProvider);
    final cameraService = ref.watch(cameraProvider);

    final isCritical = state.level == DrowsinessLevel.critical;

    return Scaffold(
      backgroundColor: Colors.black, // Always dark when driving
      body: Stack(
        children: [
          // Camera Preview
          SizedBox.expand(
            child: _ready && cameraService.isInitialized
                ? cameraService.buildPreview()
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          
          // Dark Overlay for less distraction
          Container(color: Colors.black.withOpacity(0.5)),

          // Flashing Red Border on Critical
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              border: Border.all(
                color: isCritical ? Colors.redAccent : Colors.transparent,
                width: isCritical ? 12.0 : 0.0,
              ),
            ),
          ),
          
          // Top Bar Elements
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // HUD Overlay
          _HUDOverlay(state),
        ],
      ),
    );
  }
}

class _HUDOverlay extends StatelessWidget {
  final DrowsinessState state;

  const _HUDOverlay(this.state);

  Color get color {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return const Color(0xFF00E676); // Neon Green
      case DrowsinessLevel.tired:
        return const Color(0xFFFFC107); // Amber
      case DrowsinessLevel.drowsy:
        return const Color(0xFFFF9800); // Orange
      case DrowsinessLevel.critical:
        return const Color(0xFFFF3D00); // Deep Red
    }
  }

  String get text {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return 'DESPIERTO';
      case DrowsinessLevel.tired:
        return 'CANSADO';
      case DrowsinessLevel.drowsy:
        return 'ALERTA';
      case DrowsinessLevel.critical:
        return '¡PELIGRO!';
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
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 2,
              shadows: [
                Shadow(color: color.withOpacity(0.8), blurRadius: 30)
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: color.withOpacity(0.4), width: 2),
              ),
              child: Text(
                'Ojos cerrados: ${state.eyeClosureDuration.toStringAsFixed(1)}s',
                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
