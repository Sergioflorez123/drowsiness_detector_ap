import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.phone,
  });

  bool get isValid => name.trim().isNotEmpty && phone.trim().isNotEmpty;
}

final emergencyContactProvider =
    StateNotifierProvider<EmergencyContactController, EmergencyContact>((ref) {
  return EmergencyContactController();
});

class EmergencyContactController extends StateNotifier<EmergencyContact> {
  static const _nameKey = 'emergency_contact_name';
  static const _phoneKey = 'emergency_contact_phone';

  EmergencyContactController()
      : super(const EmergencyContact(name: '', phone: '')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? '';
    final phone = prefs.getString(_phoneKey) ?? '';
    state = EmergencyContact(name: name, phone: phone);
  }

  Future<void> save({
    required String name,
    required String phone,
  }) async {
    final next = EmergencyContact(name: name.trim(), phone: phone.trim());
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, next.name);
    await prefs.setString(_phoneKey, next.phone);
  }
}
