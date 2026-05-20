import 'package:url_launcher/url_launcher.dart';

class EmergencyContactService {
  /// Abre WhatsApp con mensaje pre-cargado (wa.me requiere solo dígitos con código de país).
  Future<void> sendWhatsAppAlert({
    required String phone,
    required String message,
  }) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$digits?text=$encoded');
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw Exception('No se pudo abrir WhatsApp');
    }
  }
}
