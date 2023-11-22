import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; // Geolocator 패키지 추가

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
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List laps = [];

  // 앱이 시작될 때 초기 위치를 현재 위치로 설정
  void setInitialCameraPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  void stop() {
    timer!.cancel();
    setState(() {
      started = false;
    });
  }

  void reset() {
    timer!.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;

      digitSeconds = "00";
      digitMinutes = "00";
      digitHours = "00";

      started = false;
    });
  }

  void addLaps() {
    String lap = "$digitHours:$digitMinutes:$digitSeconds";
    setState(() {
      laps.add(lap);
    });
  }

  void start() {
    started = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;

      if (localSeconds > 59) {
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
        } else {
          localMinutes++;
          localSeconds = 0;
        }
      }
      setState(() {
        seconds = localSeconds;
        minutes = localMinutes;
        hours = localHours;
        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitHours = (hours >= 10) ? "$hours" : "0$hours";
        digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
      });
    });
  }

  // Directions API 키
  final String apiKey =
      'AIzaSyAGDQo5OmDqTQHEXLELWl2Oufi5onik1hs'; // Directions API 키를 채워 넣으세요

  final currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  void saveRecordTime() async {
    String postKey = getRandomString(16);
    // 시간을 시, 분, 초의 형식으로 합쳐서 문자열을 만듭니다.
    String recordTime = '$digitHours:$digitMinutes:$digitSeconds';

    try {
      await FirebaseFirestore.instance
          .collection('RecordTime')
          .doc(postKey)
          .set({
        'authorUid': currentUser?.uid, // 작성자의 UID를 저장
        'recordTime': recordTime,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("오류 : ${e.code}"),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    setInitialCameraPosition(); // 앱이 시작될 때 초기 위치를 현재 위치로 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
        iconTheme: IconThemeData(color: Colors.grey[850]),
        title: Text(
          "기록하기",
          style: TextStyle(color: Colors.grey[850]),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // 출발 위치와 도착 위치 초기화
                startLocationText = "출발위치";
                destinationLocationText = "도착위치";
                markers.clear();
                polylines.clear();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child: GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(36.615987, 127.011949), // 초기 위치를 설정해도 됨
                  zoom: 15.0,
                ),
                myLocationEnabled: true, // 이 부분을 추가
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
                border: Border.all(color: Color.fromRGBO(79, 111, 82, 1.0)),
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
                border: Border.all(color: Color.fromRGBO(79, 111, 82, 1.0)),
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
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!started) {
                      start();
                    } else {
                      stop();
                      // 팝업 표시
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
                            title: Center(child: Text('시간 기록')),
                            content: Container(
                              width: 250, // 원하는 폭으로 설정
                              height: 200, // 원하는 높이로 설정

                              child: Center(
                                child: Text(
                                  '$digitHours:$digitMinutes:$digitSeconds',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.all(10.0), // 팝업 내용의 패딩 조절
                            actions: [
                              TextButton(
                                onPressed: saveRecordTime,
                                child: Text(
                                  '저장',
                                  style: TextStyle(color: Colors.grey[850]),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // 팝업 닫기
                                },
                                child: Text(
                                  '닫기',
                                  style: TextStyle(color: Colors.grey[850]),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    (!started) ? '출발' : "도착",
                    style: TextStyle(
                      color: Colors.grey[850],
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // 반지름 설정
                    ),
                    backgroundColor:
                        Color.fromRGBO(243, 238, 234, 1.0), // 배경색 설정
                    side: BorderSide(color: Color.fromRGBO(79, 111, 82, 1.0)),
                    elevation: 0, // 테두리색과 두께 설정
                  ),
                ),
                Text(
                  "$digitHours:$digitMinutes:$digitSeconds",
                  style: TextStyle(
                    color: Colors.grey[850],
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    reset();
                  },
                  child: Text(
                    '리셋',
                    style: TextStyle(
                      color: Colors.grey[850],
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // 반지름 설정
                    ),
                    backgroundColor:
                        Color.fromRGBO(243, 238, 234, 1.0), // 배경색 설정
                    side: BorderSide(color: Color.fromRGBO(79, 111, 82, 1.0)),
                    elevation: 0, // 테두리색과 두께 설정
                  ),
                ),
              ],
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
