import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:running/components/profile_list.dart';
import 'package:running/components/record_list.dart';
import 'package:running/pages/profile_modify.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool isJoinClick = true;

  Future<String> downloadProfileImage(String imagePath) async {
    Reference ref = _storage.ref().child(imagePath);
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(color: Colors.grey[850]),
        title: Text(
          "마이페이지",
          style: TextStyle(color: Colors.grey[850]),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const MyProfileModify()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("User")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[500],
                        radius: 60.0,
                        backgroundImage:
                            NetworkImage(userData['userImage'] ?? ''),
                      ),
                      const SizedBox(
                        width: 60.0,
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 25.0,
                          ),
                          Text(
                            userData['username'],
                            style: TextStyle(
                                fontSize: 23.0, color: Colors.grey[850]),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            userData['userregion'],
                            style: TextStyle(
                                fontSize: 23.0, color: Colors.grey[850]),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 30.0,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Divider(
                    color: Colors.grey[900],
                    indent: 8,
                    endIndent: 8,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isJoinClick = false;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "개설 크루",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: !isJoinClick
                                      ? Colors.blue[300]
                                      : Colors.grey[700],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                height: 2,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 38,
                                color: !isJoinClick
                                    ? Colors.blue[300]
                                    : Colors.grey[700],
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isJoinClick = true;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "나의 기록",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: isJoinClick
                                      ? Colors.blue[300]
                                      : Colors.grey[700],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                height: 2.0,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 38,
                                color: isJoinClick
                                    ? Colors.blue[300]
                                    : Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isJoinClick)
                    MyProfilePostList(
                        currentUser:
                            currentUser), // 개설 크루를 선택한 경 우 MyProfilePostList 표시
                  if (isJoinClick) MyRecordList(currentUser: currentUser),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
