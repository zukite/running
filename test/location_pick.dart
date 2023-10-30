import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // 패키지 추가

class LocationPicker extends StatefulWidget {
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _mapController;
  LatLng? startLocation;
  LatLng? destinationLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('출발 및 도착 위치 선택'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              _showLocationPickerDialog(isStartLocation: true);
            },
            child: Text('출발 위치 선택'),
          ),
          ElevatedButton(
            onPressed: () {
              _showLocationPickerDialog(isStartLocation: false);
            },
            child: Text('도착 위치 선택'),
          ),
          if (startLocation != null)
            FutureBuilder<String?>(
              // 위도와 경도를 주소로 변환
              future: _getAddress(startLocation!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('출발 위치: ${snapshot.data}');
                }
              },
            ),
          if (destinationLocation != null)
            FutureBuilder<String?>(
              // 위도와 경도를 주소로 변환
              future: _getAddress(destinationLocation!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('도착 위치: ${snapshot.data}');
                }
              },
            ),
          Expanded(
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
              markers: _createMarkers(),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getAddress(LatLng location) async {
    final List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isEmpty) {
      return '주소를 찾을 수 없습니다.';
    }
    final Placemark placemark = placemarks[0];
    return placemark.street ?? '주소를 찾을 수 없습니다.';
  }

  void _showLocationPickerDialog({required bool isStartLocation}) {
    LatLng? selectedLocation;

    showDialog(
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
                      if (isStartLocation) {
                        setState(() {
                          startLocation = selectedLocation;
                        });
                      } else {
                        setState(() {
                          destinationLocation = selectedLocation;
                        });
                      }

                      // 주소를 가져와 화면에 표시
                      final String? address =
                          await _getAddress(selectedLocation!);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('선택한 위치 주소: $address'),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('선택'),
                ),
              ],
            );
          },
        );
      },
    );
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
}

void main() => runApp(MaterialApp(
      home: LocationPicker(),
    ));
