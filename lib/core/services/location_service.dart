import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position> getCurrent() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) throw Exception("Location denied");
    return await Geolocator.getCurrentPosition();
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
