import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  final ImagePicker _imagePicker = ImagePicker(); // 이미지 피커

  @override
  void initState() {
    super.initState();
    // 초기 데이터로 기존 게시글 데이터를 채우기
    crewNameController.text = widget.postData['crewName'];
    crewDescController.text = widget.postData['explain'];
    crewPeopleNumController.text = widget.postData['num'];
    crewRegionController.text = widget.postData['region'];
    crewUrlController.text = widget.postData['kakaoUrl'];
  }

  Future<void> updatePost() async {
    // 이미지를 업데이트하려면 이미지가 선택되었는지 확인하고 이미지 업로드를 수행합니다.
    if (_image != null) {
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
    };

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
      if (_image == null) {
        var image = await _imagePicker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          setState(() {
            _image = File(image.path).readAsBytesSync();
          });
        }
      }
    } catch (e) {
      // 이미지 피커가 이미 열려있을 때의 오류 처리
      print("이미지 피커 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // EditPost 페이지의 내용을 구현하세요.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '수정하기',
          style: TextStyle(
            color: Colors.grey[850],
          ),
        ),
        backgroundColor: Colors.grey[50],
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
                border: Border.all(color: Colors.blue),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_image != null)
                    Image.memory(
                      _image!,
                      fit: BoxFit.fill,
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        selectImage();
                      },
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
          ),
        ),
      ),
    );
  }
}
