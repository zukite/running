import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/pages/qna_page.dart';

class AddQna extends StatefulWidget {
  const AddQna({super.key});

  @override
  State<AddQna> createState() => _AddQnaState();
}

class _AddQnaState extends State<AddQna> {
  final currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // 컨트롤러를 사용하여 입력된 텍스트를 가져옵니다.
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  String qtitle = "";
  String qdesc = "";
  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  void postQnA() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      qtitle = titleController.text; // 제목을 컨트롤러로부터 가져옴
      qdesc = contentController.text; // 내용을 컨트롤러로부터 가져옴

      if (qtitle.isNotEmpty && qdesc.isNotEmpty) {
        String postKey = getRandomString(16);
        final userInfo = await getUserInfo(currentUser!.uid); // 사용자 정보 가져오기

        await FirebaseFirestore.instance
            .collection('QnAPosts')
            .doc(postKey)
            .set({
          'key': postKey,
          'authorUid': currentUser?.uid,
          'title': qtitle,
          'desc': qdesc,
          'authorName': userInfo['username'],
          'timestamp': FieldValue.serverTimestamp(),
        });
        // 성공적으로 크루를 만들었을 때 다이얼로그 닫기
        Navigator.of(context).pop();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const QnAPage(),
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
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String userUid) async {
    final userRef =
        FirebaseFirestore.instance.collection('User').doc(currentUser?.email);
    final userData = await userRef.get();
    return userData.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(color: Colors.grey[850]),
        title: Text(
          "글 쓰기",
          style: TextStyle(color: Colors.grey[850]),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: postQnA,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력란
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: titleController, // 컨트롤러를 연결
                decoration: const InputDecoration(
                  hintText: '제목',
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // 내용 입력란

            TextFormField(
              controller: contentController, // 컨트롤러를 연결
              decoration: const InputDecoration(
                  hintText: '내용을 입력하세요',
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none)),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 페이지가 dispose 될 때 컨트롤러도 해제합니다.
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
