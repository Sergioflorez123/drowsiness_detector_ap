import 'package:url_launcher/url_launcher.dart';

class EmergencyContactService {
  Future<void> sendEmergencySms({
    required String phone,
    required String message,
  }) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('sms:$phone?body=$encoded');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
