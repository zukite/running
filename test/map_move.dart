import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  MarkerId markerId = MarkerId("user_marker");
  Set<Marker> markers = Set<Marker>();

  @override
  void initState() {
    super.initState();

    // 주기적으로 마커 위치 업데이트
    Timer.periodic(Duration(seconds: 2), (timer) {
      updateMarkerPosition();
    });
  }

  void updateMarkerPosition() {
    final random = Random();
    final newPosition = LatLng(
      37.7749 + (random.nextDouble() - 0.5) * 0.01, // 임의의 위치 업데이트
      -122.4194 + (random.nextDouble() - 0.5) * 0.01,
    );

    setState(() {
      markers.clear();
      markers.add(Marker(
        markerId: markerId,
        position: newPosition,
      ));
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moving Map with Marker Example'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // 초기 지도 중심 위치
          zoom: 15.0, // 초기 줌 레벨
        ),
        markers: markers, // 마커 추가
      ),
    );
  }
}
