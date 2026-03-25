import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/location_service.dart';
import '../../data/datasources/remote/event_service.dart';

final emergencyProvider =
    StateNotifierProvider<EmergencyController, bool>((ref) {
  return EmergencyController();
});

class EmergencyController extends StateNotifier<bool> {
  final _location = LocationService();
  final _eventService = EventService();

  EmergencyController() : super(false);

  Future<void> trigger(String severity) async {
    if (state) return;

    state = true;

    try {
      final pos = await _location.getCurrent();

      await _eventService.saveEvent(
        type: 'drowsiness_alert',
        lat: pos.latitude,
        lng: pos.longitude,
        severity: severity,
      );
    } catch (e) {
      // Ignorar error si no hay GPS o red temporalmente para evitar que crashee
    }

    await Future.delayed(const Duration(seconds: 5));

    state = false;
  }
}
