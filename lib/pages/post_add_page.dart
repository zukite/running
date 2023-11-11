import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:running/pages/home_page.dart';

// import '../utils/image.dart';

class MyAddCrew extends StatefulWidget {
  const MyAddCrew({super.key});

  @override
  State<MyAddCrew> createState() => _MyAddCrewState();
}

class _MyAddCrewState extends State<MyAddCrew> {
  final currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController crewRegionController = TextEditingController();
  TextEditingController crewNameController = TextEditingController();
  TextEditingController crewDescController = TextEditingController();
  TextEditingController crewPeopleNumController = TextEditingController();
  TextEditingController crewUrlController = TextEditingController();

  String crewRegion = "";
  String crewName = "";
  String crewDesc = "";
  String crewPeopleNum = "";
  String crewUrl = "";
  String crewimageUrl = "";

  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage 인스턴스 생성

  // Uint8List? _image;
  // bool selectedImage = false; // 이미지가 선택되었는지 여부를 나타내는 변수
  void postCrew() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      if (/*crewimageUrl.isNotEmpty &&*/
          crewName.isNotEmpty &&
              crewDesc.isNotEmpty &&
              crewPeopleNum.isNotEmpty &&
              crewRegion.isNotEmpty &&
              crewUrl.isNotEmpty &&
              startLocationText.isNotEmpty &&
              destinationLocationText.isNotEmpty) {
        String postKey = getRandomString(16);

        if (_image != null) {
          // 이미지 업로드
          String imagePath = "post_images/${currentUser?.uid}_$postKey.jpg";
          Reference ref = _storage.ref().child(imagePath);
          UploadTask uploadTask = ref.putData(_image!);

          TaskSnapshot snapshot = await uploadTask;
          if (snapshot.state == TaskState.success) {
            String downloadUrl = await ref.getDownloadURL();
            crewimageUrl = downloadUrl;
          }
        }

        // 주소를 위도와 경도로 변환
        GeoPoint? startLocationPoint =
            await _getGeoPointFromAddress(startLocationText);
        GeoPoint? destinationLocationPoint =
            await _getGeoPointFromAddress(destinationLocationText);

        final userInfo = await getUserInfo(currentUser!.uid); // 사용자 정보 가져오기
        await FirebaseFirestore.instance.collection('Posts').doc(postKey).set({
          'key': postKey,
          'authorName': userInfo['username'],
          'authorUid': currentUser?.uid, // 작성자의 UID를 저장
          'imageUrl': crewimageUrl,
          'crewName': crewName,
          'explain': crewDesc,
          'num': crewPeopleNum,
          'region': crewRegion,
          'kakaoUrl': crewUrl,
          'startLocationText': startLocationText, // 'startLocationText' 필드 추가
          'destinationLocationText': destinationLocationText,
          'startLocation': startLocationPoint, // 변환된 위도와 경도 저장
          'destinationLocation': destinationLocationPoint,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 성공적으로 크루를 만들었을 때 다이얼로그 닫기
        Navigator.of(context).pop();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(),
          ),
        );
      } else {
        // 필수 필드가 비어 있음을 사용자에게 알릴 수 있도록 메시지 표시
        // 다이얼로그 닫기
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("필수 필드를 모두 입력하세요."),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("오류 : ${e.code}"),
        ),
      );
    } finally {
      // 게시물 작성이 완료되면 이미지 초기화
      setState(() {
        _image = null;
        selectedImage = false;
      });
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

  Uint8List? _image;
  bool selectedImage = false; // 이미지가 선택되었는지 여부를 나타내는 변수
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> selectImage() async {
    var image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        // 이미지 파일을 Uint8List로 변환하여 _image에 저장
        _image = File(image.path).readAsBytesSync();
        selectedImage = true; // 이미지가 선택되었음을 표시
      });
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String userUid) async {
    final userRef =
        FirebaseFirestore.instance.collection('User').doc(currentUser?.email);
    final userData = await userRef.get();
    return userData.data() as Map<String, dynamic>;
  }

  GoogleMapController? _mapController;
  LatLng? selectedLocation;
  LatLng? startLocation;
  LatLng? destinationLocation;

  Future<String>? _getAddress(LatLng location) async {
    final List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isEmpty) {
      return '주소를 찾을 수 없습니다.';
    }
    final Placemark placemark = placemarks[0];
    return placemark.street ?? '주소를 찾을 수 없습니다.';
  }

  Set<Marker> _markers = Set<Marker>();

  Future<void> showLocationPickDialog({required bool isStartLocation}) async {
    LatLng? selectedLocation;
    String? selectedAddress;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: 300, // Adjust the height as needed
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
                  onTap: (location) async {
                    setState(() {
                      selectedLocation = location;
                      _markers.clear();
                      _markers.add(
                        Marker(
                          markerId: MarkerId("SelectedLocation"),
                          position: selectedLocation!,
                        ),
                      );
                    });
                    // 선택된 위치에 대한 주소 가져오기
                    selectedAddress = await _getAddress(selectedLocation!);
                  },
                  markers: _markers,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
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
    // 다이얼로그가 닫힌 후에 주소를 가져와 업데이트
    if (selectedLocation != null) {
      final String? address = await _getAddress(selectedLocation!);
      if (address != null) {
        if (isStartLocation) {
          setState(() {
            startLocationText = address;
            locationTextColor = Colors.black; // 주소를 가져온 후 색상을 변경
          });
        } else {
          setState(() {
            destinationLocationText = address;
            locationTextColor = Colors.black; // 주소를 가져온 후 색상을 변경
          });
        }
      }
    }
  }

  String startLocationText = "출발위치"; // 초기에는 "시작위치 찾기"로 설정
  String destinationLocationText = "도착위치";
  Color? locationTextColor = Colors.grey[500]; // 초기 텍스트 색상

  List<String> regionList = [
    '강남구',
    '강동구',
    '강북구',
    '강서구',
    '관악구',
    '광진구',
    '구로구',
    '금천구',
    '노원구',
    '도봉구',
    '동대문구',
    '동작구',
    '마포구',
    '서대문구',
    '서초구',
    '성동구',
    '성북구',
    '송파구',
    '양천구',
    '영등포구',
    '용산구',
    '은평구',
    '종로구',
    '중구',
    '중랑구',
  ];

  void regionEditField(String field) async {
    final selectedRegion = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView(
              children: regionList.map((region) {
                return ListTile(
                  title: Text(region),
                  onTap: () {
                    setState(() {
                      crewRegion = region;
                    });
                    Navigator.pop(context, region);
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );

    // 선택한 지역을 `crewRegion` 변수에 저장한 후 화면 다시 그리도록 업데이트
    if (selectedRegion != null) {
      setState(() {
        crewRegion = selectedRegion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
        iconTheme: IconThemeData(
          color: Colors.grey[850],
        ),
        title: Text(
          "크루 개설",
          style: TextStyle(
            color: Colors.grey[850],
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // 화면 클릭해서 키보드 내리기
          },
          child: Column(
            children: [
              const SizedBox(height: 10),
              selectedImage
                  ? GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromRGBO(79, 111, 82, 1.0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.memory(
                            _image!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      onTap: selectImage,
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Color.fromRGBO(79, 111, 82, 1.0)),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add_a_photo,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          selectImage();
                        },
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
                  onChanged: (value) {
                    crewName = value;
                  },
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
                  onChanged: (value) {
                    crewDesc = value;
                  },
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
                    prefixIcon: Icon(
                      Icons.people,
                      color: Colors.grey[600],
                    ),
                    hintText: "참여 가능한 인원",
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    crewPeopleNum = value;
                  },
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  regionEditField(crewRegion);
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 5),
                          Icon(
                            Icons.room,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                crewRegion.isNotEmpty ? crewRegion : "지역구 선택",
                                style: TextStyle(
                                  color: crewRegion.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey[500], // 검은색 또는 회색 설정
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
                        mainAxisAlignment:
                            MainAxisAlignment.start, // 아이콘을 왼쪽에 정렬
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
                                  color: locationTextColor,
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
                        mainAxisAlignment:
                            MainAxisAlignment.start, // 아이콘을 왼쪽에 정렬
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
                                  color: locationTextColor,
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
                  onChanged: (value) {
                    crewUrl = value;
                  },
                ),
              ),
              // const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: postCrew,
          child: const Text("크루 만들기"),
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
