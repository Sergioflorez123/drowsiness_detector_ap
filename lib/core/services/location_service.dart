import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position> getCurrent() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) throw Exception('Location denied');
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Fast warm-up for maps (may be null on cold start).
  Future<Position?> getLastKnown() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) return null;
    return Geolocator.getLastKnownPosition();
  }

  Stream<Position> stream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
