import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrent() async {
    await Geolocator.requestPermission();
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
