import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickDialog extends StatefulWidget {
  final bool isStartLocation;
  final Function() showLocationPickDialog; // Callback function

  const LocationPickDialog({
    super.key,
    required this.isStartLocation,
    required this.showLocationPickDialog, // Pass the callback function
  });

  @override
  State<LocationPickDialog> createState() => _LocationPickDialogState();
}

class _LocationPickDialogState extends State<LocationPickDialog> {
  GoogleMapController? _mapController;
  LatLng? startLocation;
  LatLng? destinationLocation;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.isStartLocation) {
      selectedLocation = startLocation;
    } else {
      selectedLocation = destinationLocation;
    }
  }

  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {};
    if (startLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('startLocation'),
          position: startLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    if (destinationLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('destinationLocation'),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    return markers;
  }

  Future<String?> _getAddress(LatLng location) async {
    // Implement address conversion logic here
    return "Address Conversion Result"; // Replace with actual address conversion logic
  }

  void showLocationPickDialog(BuildContext context) async {
    widget.showLocationPickDialog(); // Call the callback function
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.7749, -122.4194),
                    zoom: 10,
                  ),
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  onTap: (location) {
                    setState(() {
                      selectedLocation = location;
                    });
                  },
                  markers: Set<Marker>.of(_createMarkers()
                    ..add(
                      Marker(
                        markerId: MarkerId('selectedLocation'),
                        position:
                            selectedLocation ?? LatLng(37.7749, -122.4194),
                      ),
                    )),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (selectedLocation != null) {
                      if (widget.isStartLocation) {
                        setState(() {
                          startLocation = selectedLocation;
                        });
                      } else {
                        setState(() {
                          destinationLocation = selectedLocation;
                        });
                      }

                      final String? address =
                          await _getAddress(selectedLocation!);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected Location Address: $address'),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Replace with your desired UI
  }
}
