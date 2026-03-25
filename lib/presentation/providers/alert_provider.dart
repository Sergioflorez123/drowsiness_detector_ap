import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

final alertProvider =
    StateNotifierProvider<AlertController, bool>((ref) {
  return AlertController();
});

class AlertController extends StateNotifier<bool> {
  final _player = AudioPlayer();

  AlertController() : super(false);

  Future<void> trigger() async {
    if (state) return;

    state = true;

    await _player.play(AssetSource('alarm.mp3'));

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 2000);
    }

    await Future.delayed(const Duration(seconds: 3));

    state = false;
  }
}
