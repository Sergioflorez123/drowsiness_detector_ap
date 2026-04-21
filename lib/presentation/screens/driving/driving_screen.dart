import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../data/datasources/remote/driving_remote_datasource.dart';
import '../../../domain/entities/drowsiness_state.dart';
import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
import '../../providers/camera_provider.dart';
import '../../providers/driving_session_id_provider.dart';
import '../../providers/drowsiness_provider.dart';

class DrivingScreen extends ConsumerStatefulWidget {
  const DrivingScreen({super.key});

  @override
  ConsumerState<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends ConsumerState<DrivingScreen> {
  bool _ready = false;
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await WakelockPlus.enable();
    final cameraService = ref.read(cameraProvider);
    await cameraService.initialize();

    final ds = ref.read(drivingRemoteDataSourceProvider);
    final sessionId = await ds.startDrivingSession();
    ref.read(drivingSessionIdProvider.notifier).state = sessionId;
    ref.read(drowsinessProvider.notifier).resetSessionTracking();
    _sessionStart = DateTime.now();

    await cameraService.startStream((image) {
      if (!mounted) return;
      unawaited(ref.read(drowsinessProvider.notifier).process(image));
    });

    if (!mounted) return;
    setState(() => _ready = true);

    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  void dispose() {
    unawaited(ref.read(cameraProvider).stopStream());

    final sessionId = ref.read(drivingSessionIdProvider);
    ref.read(drivingSessionIdProvider.notifier).state = null;

    if (sessionId != null && _sessionStart != null) {
      final summary =
          ref.read(drowsinessProvider.notifier).finishSessionSummary();
      final duration =
          DateTime.now().difference(_sessionStart!).inSeconds.clamp(0, 86400);
      final ds = ref.read(drivingRemoteDataSourceProvider);
      unawaited(
        ds.endDrivingSession(
          sessionId: sessionId,
          durationSeconds: duration,
          maxLevel: summary.maxLevel.name,
          secNormal: summary.secondsPerLevel[DrowsinessLevel.normal] ?? 0,
          secTired: summary.secondsPerLevel[DrowsinessLevel.tired] ?? 0,
          secDrowsy: summary.secondsPerLevel[DrowsinessLevel.drowsy] ?? 0,
          secCritical: summary.secondsPerLevel[DrowsinessLevel.critical] ?? 0,
          criticalEvents: summary.criticalBursts,
        ),
      );
    }

    ref.read(drowsinessProvider.notifier).disposeVision();
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drowsinessProvider);
    final cameraService = ref.watch(cameraProvider);
    final l = AppLocalizations.of(context)!;

    final isCritical = state.level == DrowsinessLevel.critical;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _ready && cameraService.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: cameraService.buildPreview(),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
          Container(color: Colors.black.withOpacity(0.45)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              border: Border.all(
                color: isCritical ? Colors.redAccent : Colors.transparent,
                width: isCritical ? 12 : 0,
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          _HUDOverlay(state: state, l: l),
        ],
      ),
    );
  }
}

class _HUDOverlay extends StatelessWidget {
  const _HUDOverlay({required this.state, required this.l});

  final DrowsinessState state;
  final AppLocalizations l;

  Color get color {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return const Color(0xFF00E676);
      case DrowsinessLevel.tired:
        return const Color(0xFFFFC107);
      case DrowsinessLevel.drowsy:
        return const Color(0xFFFF9800);
      case DrowsinessLevel.critical:
        return const Color(0xFFFF3D00);
    }
  }

  String get text {
    switch (state.level) {
      case DrowsinessLevel.normal:
        return l.hudAwake;
      case DrowsinessLevel.tired:
        return l.hudTired;
      case DrowsinessLevel.drowsy:
        return l.hudAlert;
      case DrowsinessLevel.critical:
        return l.hudDanger;
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
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.5,
              shadows: [
                Shadow(color: color.withOpacity(0.75), blurRadius: 28),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: color.withOpacity(0.45), width: 2),
              ),
              child: Text(
                l.hudEyesClosed(state.eyeClosureDuration.toStringAsFixed(1)),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
