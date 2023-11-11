import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running/pages/post_edit_page.dart';
import 'package:running/utils/current_location.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';

class PostDetail extends StatefulWidget {
  final Map<String, dynamic> postData;
  final User? currentUser; // 현재 사용자 정보

  const PostDetail({
    Key? key, // key를 직접 정의해야 합니다.
    required this.postData,
    required this.currentUser,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<Marker> _markers = {};
  LatLng? startLocation;
  LatLng? destinationLocation;
  GoogleMapController? _mapController;
  final CurrentLocation currentLocation = CurrentLocation();
  // Set<Polyline> _polylines = {}; // Polyline을 저장하는 집합을 생성

  void deletePost() async {
    if (widget.currentUser != null &&
        widget.currentUser!.uid == widget.postData['authorUid']) {
      try {
        // 게시물을 Firestore에서 삭제
        await _firestore
            .collection('Posts')
            .doc(widget.postData['key'])
            .delete();

        // 게시물을 삭제한 후 현재 페이지를 닫음
        Navigator.pop(context);
      } catch (e) {
        // 삭제 중에 오류가 발생한 경우 오류 처리
        print('게시물 삭제 오류: $e');
      }
    }
  }

  Future<void> _launchURL() async {
    Uri url = Uri.parse(widget.postData['kakaoUrl']);
    try {
      if (!await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw '실행할 수 없습니다';
      }
    } catch (e) {
      print('URL 열기 오류 : $e');
    }
  }

  // GoogleMap 위에 마커를 추가하고 업데이트하는 함수를 작성합니다.
  // _addMarkers 함수 수정
  void _addMarkers() {
    _markers.clear(); // 마커를 초기화합니다.

    // 시작 위치 마커 추가
    if (widget.postData['startLocation'] != null) {
      final startLocationGeoPoint = widget.postData['startLocation'];
      final startLocationLatLng = LatLng(
        startLocationGeoPoint.latitude,
        startLocationGeoPoint.longitude,
      );

      print('Start Location: $startLocationLatLng'); // 시작 위치 출력

      _markers.add(Marker(
        markerId: MarkerId("시작위치"),
        position: startLocationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: "출발 위치",
          snippet: widget.postData['startLocationText'], // 주소로 변환된 값
        ),
      ));
    }

    // 도착 위치 마커 추가
    if (widget.postData['destinationLocation'] != null) {
      final destinationLocationGeoPoint =
          widget.postData['destinationLocation'];
      final destinationLocationLatLng = LatLng(
        destinationLocationGeoPoint.latitude,
        destinationLocationGeoPoint.longitude,
      );

      print('Destination Location: $destinationLocationLatLng'); // 도착 위치 출력

      _markers.add(Marker(
        markerId: MarkerId("도착위치"),
        position: destinationLocationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: "도착 위치",
          snippet: widget.postData['destinationLocationText'], // 주소로 변환된 값
        ),
      ));
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (widget.currentUser != null) {
        setState(() {
          currentLocation.updateCurrentPosition(position);
          // Google 지도의 초기 위치를 현재 위치로 설정
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        });
      }
    } catch (e) {
      print('위치 가져오기 오류: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 위에서 작성한 함수를 initState에서 호출하여 현재 위치를 가져옵니다.
    _addMarkers(); // initState에서 _addMarkers 함수를 호출하여 마커를 추가
    // _addPolylines(); // 경로를 추가하기 위해 initState에서 _addPolylines 함수를 호출
  }

  void _onMapCreated(GoogleMapController controller) {
    // setState(() {
    //   _mapController = controller;
    //   // Google 지도가 생성되면 마커를 추가
    //   _addMarkers();

    setState(() {
      _mapController = controller;
      // 초기 위치로 이동한 후 _addMarkers 함수를 호출하지 않습니다.
      // _addMarkers 함수는 이미 initState에서 호출되었습니다.
      if (widget.postData['startLocation'] != null) {
        final startLocationGeoPoint = widget.postData['startLocation'];
        final startLocationLatLng = LatLng(
          startLocationGeoPoint.latitude,
          startLocationGeoPoint.longitude,
        );

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(startLocationLatLng),
        );
      }
    });
  }

  // _addPolylines 함수를 추가
  // void _addPolylines() {
  //   if (widget.postData['startLocation'] != null &&
  //       widget.postData['destinationLocation'] != null) {
  //     final startLocationGeoPoint = widget.postData['startLocation'];
  //     final startLocationLatLng = LatLng(
  //       startLocationGeoPoint.latitude,
  //       startLocationGeoPoint.longitude,
  //     );

  //     final destinationLocationGeoPoint =
  //         widget.postData['destinationLocation'];
  //     final destinationLocationLatLng = LatLng(
  //       destinationLocationGeoPoint.latitude,
  //       destinationLocationGeoPoint.longitude,
  //     );

  //     // Polyline 생성
  //     _polylines.add(Polyline(
  //       polylineId: PolylineId("crew_route"),
  //       color: Colors.blue, // 경로 색상
  //       width: 5, // 경로 너비
  //       points: [startLocationLatLng, destinationLocationLatLng],
  //     ));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isAuthor = widget.currentUser?.uid == widget.postData['authorUid'];
    final isCurrentUserAuthor = isAuthor;

    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      appBar: AppBar(
        title: Text(
          widget.postData['crewName'],
          style: TextStyle(
            color: Colors.grey[850],
          ),
        ),
        backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[850]),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (isCurrentUserAuthor) {
                if (value == '수정하기') {
                  // Navigate to the edit post page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPost(postData: widget.postData),
                    ),
                  );
                } else if (value == '삭제하기') {
                  // 게시물 삭제 함수 호출
                  deletePost();
                }
              } else {
                // Display a message if the current user is not the author
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("게시글의 작성자가 아닙니다"),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              final items = <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: '수정하기',
                  child: Text('수정하기'),
                ),
              ];

              if (isCurrentUserAuthor) {
                // Only show the "삭제하기" option if the current user is the author
                items.add(
                  const PopupMenuItem<String>(
                    value: '삭제하기',
                    child: Text('삭제하기'),
                  ),
                );
              }

              return items;
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    widget.postData['imageUrl'],
                    fit: BoxFit.fill,
                  ),
                ),
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          widget.postData['crewName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          widget.postData['explain'],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 300, // 필요에 따라 조정
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      currentLocation.currentPosition?.latitude ?? 0.0,
                      currentLocation.currentPosition?.longitude ?? 0.0,
                    ), // 초기 위치 (예시 위치)
                    zoom: 16, // 초기 확대 수준
                  ),
                  // markers: {
                  //   Marker(
                  //     markerId: MarkerId('marker_id'),
                  //     position: LatLng(
                  //       currentLocation.currentPosition?.latitude ?? 0.0,
                  //       currentLocation.currentPosition?.longitude ?? 0.0,
                  //     ),
                  //     infoWindow: InfoWindow(title: '현재위치'), // 마커 클릭하면 나타나는 글씨
                  //   ),
                  // },
                  markers: _markers, // 마커를 표시하기 위해 _markers 사용
                  // polylines: _polylines, // Polyline을 추가
                  myLocationEnabled: true, // 현재 위치 버튼 활성화
                  mapToolbarEnabled: true, // 지도 도구 모음 활성화
                  onMapCreated: _onMapCreated,
                  gestureRecognizers: Set()
                    ..add(Factory<PanGestureRecognizer>(
                        () => PanGestureRecognizer())),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _launchURL,
          child: Text("가입하기"),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            textStyle: TextStyle(fontSize: 15),
            backgroundColor: Color.fromRGBO(79, 111, 82, 1.0),
          ),
        ),
      ),
    );
  }
}
