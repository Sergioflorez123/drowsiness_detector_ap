import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:audio_session/audio_session.dart';

final alertProvider =
    StateNotifierProvider<AlertController, bool>((ref) {
  return AlertController();
});

class AlertController extends StateNotifier<bool> {
  final _player = AudioPlayer();
  AudioSession? _session;

  AlertController() : super(false) {
    _initSession();
  }

  Future<void> _initSession() async {
    _session = await AudioSession.instance;
    await _session!.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.sonification,
        flags: AndroidAudioFlags.audibilityEnforced,
        usage: AndroidAudioUsage.alarm,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<void> trigger() async {
    if (state) return;

    state = true;
    
    // Robaremos el focus de audio temporalmente a Spotify, Radio, etc.
    await _session?.setActive(true);

    await _player.play(AssetSource('alarm.mp3'));

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 2000);
    }

    await Future.delayed(const Duration(seconds: 3));
    
    // Regresamos el focus a la radio/plataforma de música
    await _session?.setActive(false);

    state = false;
  }
}
