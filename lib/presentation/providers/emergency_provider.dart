import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/emergency_contact_service.dart';
import '../../core/services/location_service.dart';
import '../../data/datasources/remote/event_service.dart';
import 'emergency_contact_provider.dart';

final emergencyProvider =
    StateNotifierProvider<EmergencyController, bool>((ref) {
  return EmergencyController(ref);
});

final whatsAppAlertStatusProvider = StateProvider<String?>((ref) => null);

class EmergencyController extends StateNotifier<bool> {
  EmergencyController(this._ref) : super(false);

  final Ref _ref;
  final _location = LocationService();
  final _eventService = EventService();
  final _contactService = EmergencyContactService();
  Timer? _liveTimer;

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
    if (!contact.isValid) {
      _ref.read(whatsAppAlertStatusProvider.notifier).state = 'invalid_contact';
      return;
    }

    try {
      _ref.read(whatsAppAlertStatusProvider.notifier).state = 'sending';
      final pos = await _location.getCurrent();
      final maps =
          'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
      final message =
          'ALERTA EYE ALERT: $reason. Nivel: $severity. '
          'El conductor no despierta. Ubicacion en tiempo real: $maps';

      await _contactService.sendWhatsAppAlert(
        phone: contact.phone,
        message: message,
      );
      _ref.read(whatsAppAlertStatusProvider.notifier).state = 'sent';
    } catch (_) {
      _ref.read(whatsAppAlertStatusProvider.notifier).state = 'error';
    }
  }

  Future<void> startLiveEmergencyTracking() async {
    _liveTimer ??= Timer.periodic(const Duration(seconds: 20), (_) async {
      try {
        final pos = await _location.getCurrentFast();
        await _eventService.saveEvent(
          type: 'critical_live_tracking',
          lat: pos.latitude,
          lng: pos.longitude,
          severity: 'critical',
        );

        // Solo persistimos ubicación en backend; WhatsApp se abre al entrar en crítico.
      } catch (_) {}
    });
  }

  void stopLiveEmergencyTracking() {
    _liveTimer?.cancel();
    _liveTimer = null;
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }
}
