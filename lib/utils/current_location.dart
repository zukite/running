import 'package:geolocator/geolocator.dart';

class CurrentLocation {
  Position? _currentPosition;

  Future<void> getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Position? get currentPosition => _currentPosition;
}
