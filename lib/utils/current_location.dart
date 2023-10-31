import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocation {
  LatLng? _currentPosition;

  void updateCurrentPosition(Position position) {
    _currentPosition = LatLng(position.latitude, position.longitude);
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      updateCurrentPosition(position);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  LatLng? get currentPosition => _currentPosition;
}
