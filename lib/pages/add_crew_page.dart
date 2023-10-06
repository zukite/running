// import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:running/pages/home_page.dart';

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

  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  // final ImagePicker _picker = ImagePicker();

  void postCrew() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Future<void> pickAndUploadImage() async {
    //   final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    //   if (pickedFile != null) {
    //     final File imageFile = File(pickedFile.path);
    //     final String postKey = getRandomString(16);
    //     final Reference storageReference =
    //         FirebaseStorage.instance.ref().child('crew_images/$postKey.jpg');

    //     showDialog(
    //       context: context,
    //       builder: (context) => const Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     );
    //     try {
    //       final UploadTask uploadTask = storageReference.putFile(
    //         imageFile,
    //         SettableMetadata(contentType: 'image/jpeg'),
    //       );

    //       await uploadTask.whenComplete(() async {
    //         final imageUrl = await storageReference.getDownloadURL();

    //         await FirebaseFirestore.instance
    //             .collection('Posts')
    //             .doc(postKey)
    //             .set({
    //           'key': postKey,
    //           'authorName': currentUser?.displayName,
    //           'crewName': crewName,
    //           'explain': crewDesc,
    //           'num': crewPeopleNum,
    //           'region': crewRegion,
    //           'kakaoUrl': crewUrl,
    //           'imageUrl': imageUrl,
    //         });

    //         Navigator.of(context).pop();
    //         Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => MyHomePage(),
    //           ),
    //         );
    //       });
    //     } on FirebaseAuthException catch (e) {
    //       Navigator.of(context).pop();
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text("오류 : ${e.code}"),
    //         ),
    //       );
    //     }
    //   }
    try {
      if (crewName.isNotEmpty &&
          crewDesc.isNotEmpty &&
          crewPeopleNum.isNotEmpty &&
          crewRegion.isNotEmpty &&
          crewUrl.isNotEmpty) {
        String postKey = getRandomString(16);

        await FirebaseFirestore.instance.collection('Posts').doc(postKey).set({
          'key': postKey,
          'authorName': currentUser?.email?.split('@')[0],
          'crewName': crewName,
          'explain': crewDesc,
          'num': crewPeopleNum,
          'region': crewRegion,
          'kakaoUrl': crewUrl,
          // 'imageUrl':imageUrl,
          // 'like':0,
        });
        Navigator.of(context).pop(); // 다이얼로그 닫기
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyHomePage()), // MyHomePage는 실제 홈 화면 위젯에 대한 클래스명으로 수정해야 합니다.
        );
      } else {
        // 필수 필드가 비어 있음을 사용자에게 알릴 수 있도록 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("필수 필드를 모두 입력하세요."),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // pop loding circle
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("오류 : ${e.code}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add_a_photo,
                    color: Colors.grey[500],
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: crewNameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
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
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
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
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
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
                  onChanged: (value) {
                    crewPeopleNum = value;
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: crewRegionController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
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
                  onChanged: (value) {
                    crewRegion = value;
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: crewUrlController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
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
              const SizedBox(height: 8),
              ElevatedButton(onPressed: postCrew, child: const Text("크루 만들기")),
            ],
          ),
        ),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   throw UnimplementedError();
  // }

