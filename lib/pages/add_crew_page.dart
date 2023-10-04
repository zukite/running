import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  void postCrew() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      String postKey = getRandomString(16);
      FirebaseFirestore.instance.collection('Posts').doc(postKey).set({
        'key': postKey,
        'authorName': currentUser,
        'crewName': crewName,
        'explain': crewDesc,
        'num': crewPeopleNum,
        'region': crewRegion,
        'kakaoUrl': crewUrl,
        // 'like':0,
      });

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loding circle
      Navigator.pop(context);
      //show error to user
      print(e.code);
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
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.grey[500],
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
