import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/emergency_contact_service.dart';
import '../../core/services/location_service.dart';
import '../../data/datasources/remote/event_service.dart';
import 'emergency_contact_provider.dart';

final emergencyProvider =
    StateNotifierProvider<EmergencyController, bool>((ref) {
  return EmergencyController(ref);
});

class EmergencyController extends StateNotifier<bool> {
  EmergencyController(this._ref) : super(false);

  final Ref _ref;
  final _location = LocationService();
  final _eventService = EventService();
  final _contactService = EmergencyContactService();

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

  Future<void> triggerContactAlert({
    required String severity,
    required String reason,
  }) async {
    final contact = _ref.read(emergencyContactProvider);
    if (!contact.isValid) return;

    try {
      final pos = await _location.getCurrent();
      final maps =
          'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
      final message =
          'ALERTA EYE ALERT: $reason. Nivel: $severity. '
          'Ubicacion del conductor: $maps';

      await _contactService.sendEmergencySms(
        phone: contact.phone,
        message: message,
      );
    } catch (_) {
      // Ignore to avoid app interruption.
    }
  }
}
