// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/pages/profile_modify.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  // 사용자 정보
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isJoinClick = true;

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
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
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
      // body: Row(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     const Padding(
      //       padding: EdgeInsets.fromLTRB(30, 30, 0, 0),
      //       child: CircleAvatar(
      //         radius: 55,
      //         backgroundColor: Colors.grey,
      //       ),
      //     ),
      //     Center(
      //       child: Column(
      //         children: [
      //           Padding(
      //             padding: const EdgeInsets.fromLTRB(40, 55, 0, 20),
      //             child: Text(currentUser.email!.split("@")[0]),
      //           ),
      //           Text(),
      //         ],
      //       ),
      //     )
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 사진
                CircleAvatar(
                  backgroundColor: Colors.grey[500],
                  radius: 50.0,
                ),
                const SizedBox(
                  width: 30.0,
                ),
                const Column(
                  children: [
                    SizedBox(
                      height: 25.0,
                    ),
                    Text(
                      "닉네임",
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "신사동 / 용현동",
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 30.0,
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
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
                          width: 167,
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
                          "가입 크루",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: isJoinClick
                                ? Colors.blue[300]
                                : Colors.grey[700],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 2,
                          width: 167,
                          color:
                              isJoinClick ? Colors.blue[300] : Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // if (isJoinClick)
            //   Container(
            //     child: const Text("가입 크루 클릭"),
            //   ),
            // if (!isJoinClick)
            //   Container(
            //     child: const Text("개설 크루 클릭"),
            //   ),
          ],
        ),
      ),
    );
  }
}
