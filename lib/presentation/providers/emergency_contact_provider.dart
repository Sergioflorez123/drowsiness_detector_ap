import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/activity_log_datasource.dart';
import '../../data/datasources/remote/emergency_contact_datasource.dart';

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
  return EmergencyContactController(
    ref.read(emergencyContactDataSourceProvider),
    ref.read(activityLogDataSourceProvider),
  );
});

class EmergencyContactController extends StateNotifier<EmergencyContact> {
  static const _nameKey = 'emergency_contact_name';
  static const _phoneKey = 'emergency_contact_phone';

  EmergencyContactController(this._remote, this._activityLog)
      : super(const EmergencyContact(name: '', phone: '')) {
    _load();
  }

  final EmergencyContactDataSource _remote;
  final ActivityLogDataSource _activityLog;

  Future<void> _load() async {
    final remote = await _remote.fetch();
    if (remote != null) {
      state = EmergencyContact(name: remote.name, phone: remote.phone);
      await _cacheLocal(remote.name, remote.phone);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    state = EmergencyContact(
      name: prefs.getString(_nameKey) ?? '',
      phone: prefs.getString(_phoneKey) ?? '',
    );
  }

  Future<void> _cacheLocal(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_phoneKey, phone);
  }

  Future<bool> save({
    required String name,
    required String phone,
  }) async {
    final next = EmergencyContact(name: name.trim(), phone: phone.trim());
    state = next;
    await _cacheLocal(next.name, next.phone);

    try {
      await _remote.upsert(name: next.name, phone: next.phone);
      await _activityLog.log(
        activityType: ActivityType.emergencyContactSaved,
        details: {'name': next.name, 'phone': next.phone},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
