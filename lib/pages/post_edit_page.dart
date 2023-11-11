import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditPost extends StatefulWidget {
  final Map<String, dynamic> postData;

  EditPost({
    Key? key,
    required this.postData,
  }) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  TextEditingController crewNameController = TextEditingController();
  TextEditingController crewDescController = TextEditingController();
  TextEditingController crewPeopleNumController = TextEditingController();
  TextEditingController crewRegionController = TextEditingController();
  TextEditingController crewUrlController = TextEditingController();
  Uint8List? _image; // 이미지 데이터를 저장하기 위한 변수
  String? imageUrl; // imageUrl 변수 선언
  final ImagePicker _imagePicker = ImagePicker(); // 이미지 피커
  LatLng? startLocation;
  LatLng? destinationLocation;
  GoogleMapController? _mapController;
  String? startLocationText;
  String? destinationLocationText;
  bool selectedImage = false; // 이미지가 선택되었는지 여부를 나타내는 변수

  @override
  void initState() {
    super.initState();
    // 초기 데이터로 기존 게시글 데이터를 채우기

    crewNameController.text = widget.postData['crewName'];
    crewDescController.text = widget.postData['explain'];
    crewPeopleNumController.text = widget.postData['num'];
    crewRegionController.text = widget.postData['region'];
    crewUrlController.text = widget.postData['kakaoUrl'];
    startLocationText = widget.postData['startLocationText'] ?? '';
    destinationLocationText = widget.postData['destinationLocationText'] ?? '';
    imageUrl = widget.postData['imageUrl'] ?? ''; // imageUrl 초기화
  }

  Future<void> updatePost() async {
    // 이미지가 선택되지 않았을 경우 Firebase Storage에 업로드를 수행하지 않음
    if (selectedImage) {
      String imagePath =
          "post_images/${widget.postData['authorUid']}_${widget.postData['key']}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(imagePath);
      UploadTask uploadTask = ref.putData(_image!);

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        String downloadUrl = await ref.getDownloadURL();
        widget.postData['imageUrl'] = downloadUrl;
      }
    }

    // 새로운 게시글 데이터를 가져와서 Firestore 업데이트
    final updatedData = {
      'crewName': crewNameController.text,
      'explain': crewDescController.text,
      'num': crewPeopleNumController.text,
      'region': crewRegionController.text,
      'kakaoUrl': crewUrlController.text,
      'imageUrl': widget.postData['imageUrl'], // 이미지 URL을 업데이트한 URL로 변경
      'startLocationText': startLocationText, // 새로운 주소 업데이트
      'destinationLocationText': destinationLocationText, // 새로운 주소 업데이트
    };
    if (startLocationText != null) {
      GeoPoint? startLocationPoint =
          await _getGeoPointFromAddress(startLocationText!);
      if (startLocationPoint != null) {
        updatedData['startLocation'] = startLocationPoint;
      }
    }

    if (destinationLocationText != null) {
      GeoPoint? destinationLocationPoint =
          await _getGeoPointFromAddress(destinationLocationText!);
      if (destinationLocationPoint != null) {
        updatedData['destinationLocation'] = destinationLocationPoint;
      }
    }

    // Firestore에서 해당 게시물 업데이트
    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.postData['key'])
        .update(updatedData);

    // 수정이 완료되면 이전 화면으로 이동 또는 작업 완료 메시지 표시
    Navigator.pop(context);
  }

  Future<void> selectImage() async {
    try {
      var image = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _image = File(image.path).readAsBytesSync();
          // 이미지가 선택되었으므로 selectedImage를 true로 설정
          selectedImage = true;
        });
      }
    } catch (e) {
      // 이미지 피커가 이미 열려있을 때의 오류 처리
      print("이미지 피커 오류: $e");
    }
  }

  Future<String>? _getAddress(LatLng location) async {
    final List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isEmpty) {
      return '주소를 찾을 수 없습니다.';
    }
    final Placemark placemark = placemarks[0];
    return placemark.street ?? '주소를 찾을 수 없습니다.';
  }

  Set<Marker> _markers = {};

  Future<void> showLocationPickDialog({required bool isStartLocation}) async {
    LatLng? selectedLocation;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: 300, // 필요에 따라 조정
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.7749, -122.4194), // 초기 위치
                    zoom: 10, // 초기 확대 수준
                  ),
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  onTap: (location) async {
                    setState(() {
                      selectedLocation = location;
                    });
                    //     },
                    //     markers: Set<Marker>.from([
                    //       if (startLocation != null && isStartLocation)
                    //         Marker(
                    //           markerId: MarkerId("StartLocation"),
                    //           position: startLocation!,
                    //         ),
                    //       if (destinationLocation != null && !isStartLocation)
                    //         Marker(
                    //           markerId: MarkerId("DestinationLocation"),
                    //           position: destinationLocation!,
                    //         ),
                    //     ]),
                    //   ),
                    // ),

                    // 선택한 위치에 마커를 추가합니다.
                    _markers.clear();
                    _markers.add(Marker(
                      markerId: MarkerId("SelectedLocation"),
                      position: selectedLocation!,
                    ));
                  },
                  markers: _markers, // 마커를 표시합니다.
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (selectedLocation != null) {
                      if (isStartLocation) {
                        setState(() {
                          startLocation = selectedLocation;
                          startLocationText = null; // 새로운 주소 선택 시 초기화
                        });
                      } else {
                        setState(() {
                          destinationLocation = selectedLocation;
                          destinationLocationText = null; // 새로운 주소 선택 시 초기화
                        });
                      }
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

    // 다이얼로그가 닫힌 후에 주소를 가져오고 UI 업데이트
    if (selectedLocation != null) {
      final String? address = await _getAddress(selectedLocation!);
      if (address != null) {
        if (isStartLocation) {
          setState(() {
            startLocationText = address;
          });
        } else {
          setState(() {
            destinationLocationText = address;
          });
        }
      }
    }
  }

  Future<GeoPoint?> _getGeoPointFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return GeoPoint(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("주소에서 위치로 변환 중 오류 발생: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // EditPost 페이지의 내용을 구현하세요.
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      appBar: AppBar(
        title: Text(
          '수정하기',
          style: TextStyle(
            color: Colors.grey[850],
          ),
        ),
        backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
        iconTheme: IconThemeData(color: Colors.grey[850]),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 이미지 업데이트 필드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color.fromRGBO(79, 111, 82, 1.0)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: selectImage,
                    child: Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      child: selectedImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.memory(
                                _image!,
                                fit: BoxFit.fill,
                              ),
                            )
                          : imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(imageUrl!),
                                )
                              : Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey[500],
                                ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: crewNameController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                  hintText: "모임 이름",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: crewDescController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                  hintText: "모임에 대해 설명해주세요.",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(90),
                ),
                textAlign: TextAlign.center,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: crewPeopleNumController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                  prefixIcon: const Icon(Icons.people),
                  hintText: "참여 가능한 인원",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: crewRegionController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                  prefixIcon: const Icon(Icons.room),
                  hintText: "동/읍/면 찾기",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showLocationPickDialog(isStartLocation: true);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color.fromRGBO(79, 111, 82, 1.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 아이콘을 왼쪽에 정렬
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
                              startLocationText ?? '',
                              style: TextStyle(
                                color: Colors.black,
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
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showLocationPickDialog(isStartLocation: false);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color.fromRGBO(79, 111, 82, 1.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 아이콘을 왼쪽에 정렬
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
                              destinationLocationText ?? '',
                              style: TextStyle(
                                color: Colors.black,
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
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: crewUrlController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey[300],
                  filled: true,
                  prefixIcon: const Icon(Icons.chat_bubble),
                  hintText: "URL 입력",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: updatePost,
          child: const Text("수정하기"),
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
