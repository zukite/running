import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/text_box.dart';

class MyProfileModify extends StatefulWidget {
  const MyProfileModify({super.key});

  @override
  State<MyProfileModify> createState() => _MyProfileModifyState();
}

class _MyProfileModifyState extends State<MyProfileModify> {
  // 사용자 정보
  final currentUser = FirebaseAuth.instance.currentUser!;

  // 모든 사용자
  final userCollection = FirebaseFirestore.instance.collection("User");

  // 닉네임 수정 함수
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "$field 수정하기",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.grey[850]),
          decoration: InputDecoration(
            hintText: "$field(을)를 입력하세요. ",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "저장",
              style: TextStyle(color: Colors.grey[850]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "취소",
              style: TextStyle(color: Colors.grey[850]),
            ),
          ),
        ],
      ),
    );

    // 파이어스토어에 업데이트
    if (newValue.trim().isNotEmpty) {
      await userCollection.doc(currentUser.email).update({field: newValue});
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
        elevation: 0.0,
        title: Text(
          "프로필 수정",
          style: TextStyle(color: Colors.grey[850]),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {},
        //     child: Text(
        //       "완료",
        //       style: TextStyle(color: Colors.grey[850], fontSize: 20),
        //     ),
        //   ),
        // ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("User")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 50),

                // 프로필 수정
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(
                  height: 50,
                ),

                // 닉네임 수정
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    "닉네임",
                    style: TextStyle(
                      color: Colors.grey[850],
                      fontSize: 18,
                    ),
                  ),
                ),
                MyTextBox(
                  text: userData["username"],
                  onPressed: () => editField('username'),
                ),
                const SizedBox(
                  height: 30,
                ),

                // 지역설정
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    "지역 설정",
                    style: TextStyle(
                      color: Colors.grey[850],
                      fontSize: 18,
                    ),
                  ),
                ),
                MyTextBox(
                  text: userData["userregion"],
                  onPressed: () => editField('userregion'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
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
