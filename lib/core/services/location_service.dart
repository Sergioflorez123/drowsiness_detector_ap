import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<bool> _ensurePermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<Position> getCurrent() async {
    final granted = await _ensurePermission();
    if (!granted) throw Exception('Location denied');
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<Position> getCurrentFast() async {
    final granted = await _ensurePermission();
    if (!granted) throw Exception('Location denied');
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );
  }

  /// Fast warm-up for maps (may be null on cold start).
  Future<Position?> getLastKnown() async {
    final granted = await _ensurePermission();
    if (!granted) return null;
    return Geolocator.getLastKnownPosition();
  }

  Stream<Position> stream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 3,
      ),
    );
  }
}
