import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    ref.read(drowsinessProvider.notifier).start();
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    ref.read(drowsinessProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drowsinessProvider);
    final cameraService = ref.watch(cameraProvider);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: _ready && cameraService.isInitialized
                ? cameraService.buildPreview()
                : const ColoredBox(color: Colors.black),
          ),
          _OverlayUI(state),
        ],
      ),
    );
  }
}

class _OverlayUI extends StatelessWidget {
  final DrowsinessState state;

  const _OverlayUI(this.state);

  Color get color {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return Colors.green;
      case DrowsinessLevel.tired:
        return Colors.yellow;
      case DrowsinessLevel.drowsy:
        return Colors.orange;
      case DrowsinessLevel.critical:
        return Colors.red;
    }
  }

  String get text {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return 'Awake';
      case DrowsinessLevel.tired:
        return 'Tired';
      case DrowsinessLevel.drowsy:
        return 'Drowsy';
      case DrowsinessLevel.critical:
        return 'Wake up!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(217),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Eyes closed: ${state.eyeClosureDuration.toStringAsFixed(2)}s',
            ),
          ],
        ),
      ),
    );
  }
}

