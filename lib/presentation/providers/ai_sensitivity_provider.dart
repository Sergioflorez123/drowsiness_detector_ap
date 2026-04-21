import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final aiSensitivityProvider =
    StateNotifierProvider<AiSensitivityController, double>((ref) {
  return AiSensitivityController();
});

class AiSensitivityController extends StateNotifier<double> {
  static const _prefsKey = 'ai_sensitivity';

  AiSensitivityController() : super(0.4) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_prefsKey) ?? 0.4;
  }

  Future<void> setSensitivity(double value) async {
    state = value.clamp(0.1, 0.8);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKey, state);
  }
}
