import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAddCrew extends StatefulWidget {
  const MyAddCrew({super.key});

  @override
  State<MyAddCrew> createState() => _MyAddCrewState();
}

class _MyAddCrewState extends State<MyAddCrew> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String? crewRegion, crewName, crewDesc, crewPeopleNum, crewUrl;
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
        child: Container(
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
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
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
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
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
                  onChanged: (value) {
                    crewDesc = value;
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.grey[300],
                    filled: true,
                    prefixIcon: Icon(Icons.people),
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
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.grey[300],
                    filled: true,
                    prefixIcon: Icon(Icons.room),
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
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.grey[300],
                    filled: true,
                    prefixIcon: Icon(Icons.chat_bubble),
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
            ],
          ),
        ),
      ),
    );
  }
}
