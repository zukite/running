import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  String startLocationText = "출발위치";
  String destinationLocationText = "도착위치";

  // Directions API 키
  final String apiKey = 'AIzaSyAGDQo5OmDqTQHEXLELWl2Oufi5onik1hs';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(color: Colors.grey[850]),
        title: Text(
          "기록하기",
          style: TextStyle(color: Colors.grey[850]),
        ),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Container(
              height: 500,
              child: GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194),
                  zoom: 15.0,
                ),
                onTap: (LatLng location) async {
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                      location.latitude, location.longitude);
                  if (placemarks.isNotEmpty) {
                    Placemark placemark = placemarks[0];
                    String address = placemark.street ?? "";
                    setState(() {
                      if (startLocationText == "출발위치") {
                        startLocationText = "$address";
                        markers.add(
                          Marker(
                            markerId: MarkerId('start'),
                            position: location,
                            infoWindow: InfoWindow(title: '출발 위치'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                          ),
                        );
                      } else {
                        destinationLocationText = "$address";
                        markers.add(
                          Marker(
                            markerId: MarkerId('destination'),
                            position: location,
                            infoWindow: InfoWindow(title: '도착 위치'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                          ),
                        );
                        // 경로 그리기
                        _drawRoute();
                      }
                    });
                  }
                },
                markers: markers,
                polylines: polylines,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.room,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            startLocationText,
                            style: TextStyle(
                              color: Colors.grey[850],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.room,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            destinationLocationText,
                            style: TextStyle(
                              color: Colors.grey[850],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 경로 그리기 메소드
  void _drawRoute() async {
    if (markers.length < 2) {
      return; // 출발지와 도착지 마커가 없으면 그리지 않음
    }

    LatLng startLocation = markers
        .firstWhere((marker) => marker.markerId.value == 'start')
        .position;
    LatLng destinationLocation = markers
        .firstWhere((marker) => marker.markerId.value == 'destination')
        .position;

    // Directions API를 사용하여 경로 정보 가져오기
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${startLocation.latitude},${startLocation.longitude}&'
        'destination=${destinationLocation.latitude},${destinationLocation.longitude}&'
        'mode=walking&'
        'key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> polylineCoordinates = [];
        data['routes'][0]['legs'][0]['steps'].forEach((step) {
          polylineCoordinates.add(LatLng(
            step['start_location']['lat'],
            step['start_location']['lng'],
          ));
          polylineCoordinates.add(LatLng(
            step['end_location']['lat'],
            step['end_location']['lng'],
          ));
        });

        PolylineId id = PolylineId("poly");
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.blue,
          points: polylineCoordinates,
          width: 4,
        );

        setState(() {
          polylines.add(polyline);
        });
      }
    }
  }
}