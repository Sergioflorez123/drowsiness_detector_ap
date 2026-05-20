import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:audio_session/audio_session.dart' as session;

import '../../domain/entities/drowsiness_state.dart';

final alertProvider =
    StateNotifierProvider<AlertController, bool>((ref) {
  return AlertController();
});

/// Vibración y sonido sostenidos mientras el nivel no sea normal (verde).
class AlertController extends StateNotifier<bool> {
  final _player = AudioPlayer();
  session.AudioSession? _session;
  DrowsinessLevel? _activeLevel;
  Timer? _vibrationTimer;
  bool _isLooping = false;

  AlertController() : super(false) {
    _initSession();
  }

  Future<void> _initSession() async {
    _session = await session.AudioSession.instance;
    await _session!.configure(session.AudioSessionConfiguration(
      avAudioSessionCategory: session.AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          session.AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: session.AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          session.AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions:
          session.AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const session.AndroidAudioAttributes(
        contentType: session.AndroidAudioContentType.sonification,
        flags: session.AndroidAudioFlags.audibilityEnforced,
        usage: session.AndroidAudioUsage.alarm,
      ),
      androidAudioFocusGainType:
          session.AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: true,
    ));
  }

  /// Alinea alertas con el nivel actual: vibración constante hasta volver a normal.
  Future<void> syncWithLevel(DrowsinessLevel level) async {
    if (level == DrowsinessLevel.normal) {
      await stopAlert();
      return;
    }

    final previousLevel = _activeLevel;
    final escalated = previousLevel == null || level.index > previousLevel.index;
    _activeLevel = level;

    if (level == DrowsinessLevel.critical && !_isLooping) {
      _isLooping = true;
      state = true;
      await _session?.setActive(true);
      await _playAlarmLoop();
    } else if (!_isLooping) {
      if (!state) {
        state = true;
        await _session?.setActive(true);
        await _playAlarmOnce();
      } else if (escalated) {
        await _playAlarmOnce();
      }
    }

    await _restartVibration(level);
  }

  Future<void> _playAlarmOnce() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.play(AssetSource('sounds/tone-evacuation.mp3'));
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  Future<void> _playAlarmLoop() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/tone-evacuation.mp3'));
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  Future<void> _restartVibration(DrowsinessLevel level) async {
    _vibrationTimer?.cancel();
    await Vibration.cancel();

    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;

    final pulseMs = switch (level) {
      DrowsinessLevel.critical => 900,
      DrowsinessLevel.drowsy => 650,
      _ => 450,
    };

    Future<void> pulse() async {
      if (!state) return;
      await Vibration.vibrate(duration: pulseMs);
    }

    await pulse();
    _vibrationTimer = Timer.periodic(
      const Duration(milliseconds: 1100),
      (_) => pulse(),
    );
  }

  Future<void> stopAlert() async {
    if (!state && _activeLevel == null && !_isLooping) return;

    _activeLevel = null;
    state = false;
    _isLooping = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    await Vibration.cancel();
    try {
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.stop();
    } catch (_) {}
    await _session?.setActive(false);
  }

  @override
  void dispose() {
    _vibrationTimer?.cancel();
    Vibration.cancel();
    _player.dispose();
    super.dispose();
  }
}
