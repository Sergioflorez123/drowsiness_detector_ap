import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:audio_session/audio_session.dart' as session;

final alertProvider =
    StateNotifierProvider<AlertController, bool>((ref) {
  return AlertController();
});

class AlertController extends StateNotifier<bool> {
  final _player = AudioPlayer();
  session.AudioSession? _session;

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

  Future<void> trigger({String severity = 'critical'}) async {
    if (state) return;

    state = true;

    await _session?.setActive(true);

    try {
      await _player.play(AssetSource('alarm.wav'));
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }

    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      if (severity == 'critical') {
        Vibration.vibrate(pattern: [0, 700, 300, 900], repeat: -1);
      } else {
        Vibration.vibrate(pattern: [0, 300, 220, 300], repeat: -1);
      }
    }

    await Future.delayed(
      Duration(seconds: severity == 'critical' ? 5 : 3),
    );
    await Vibration.cancel();

    await _session?.setActive(false);

    state = false;
  }
}
