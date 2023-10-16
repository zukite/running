import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:running/components/text_box.dart';
import 'package:running/pages/profile_page.dart';
import 'package:running/utils/image.dart';

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

  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage 인스턴스 생성

  Uint8List? _image;
  bool selectedImage = false; // 이미지가 선택되었는지 여부를 나타내는 변수

  // 닉네임 수정 함수
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "$field 수정하기",
          style: const TextStyle(color: Colors.grey),
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

  Future<void> selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
      selectedImage = true; // 이미지가 선택되었음을 표시
    });
    if (_image != null) {
      // Firebase Storage에 이미지 업로드
      String imagePath = "profile_images/${currentUser.uid}.jpg";
      Reference ref = _storage.ref().child(imagePath);
      UploadTask uploadTask = ref.putData(_image!);

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        // 이미지 업로드 성공 시 Firestore에 이미지 다운로드 URL 저장
        String downloadUrl = await ref.getDownloadURL();
        await userCollection
            .doc(currentUser.email)
            .update({"userImage": downloadUrl});
      }
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MyProfilePage(),
                ),
              );
            },
            icon: const Icon(Icons.save_alt),
          ),
        ],
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
                Center(
                  child: Stack(
                    children: [
                      (selectedImage && (_image != null))
                          ? CircleAvatar(
                              radius: 55,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : const CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                            ),
                      Positioned(
                        bottom: -8,
                        left: 68,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                ),
                // 프로필 수정

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
