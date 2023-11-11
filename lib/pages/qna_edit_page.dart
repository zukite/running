import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QnaEdit extends StatefulWidget {
  final String documentId;
  final String initialTitle;
  final String initialDescription;

  QnaEdit({
    required this.documentId,
    required this.initialTitle,
    required this.initialDescription,
  });

  @override
  _QnaEditState createState() => _QnaEditState();
}

class _QnaEditState extends State<QnaEdit> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle;
    descriptionController.text = widget.initialDescription;
  }

  void updatePost() {
    // Firestore에서 게시물 업데이트
    FirebaseFirestore.instance
        .collection('QnAPosts')
        .doc(widget.documentId)
        .update({
      'title': titleController.text,
      'desc': descriptionController.text,
    });

    // 수정이 완료되면 현재 페이지를 닫음
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
        iconTheme: IconThemeData(color: Colors.grey[850]),
        elevation: 0.0,
        title: Text(
          "게시물 수정",
          style: TextStyle(color: Colors.grey[850]),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save_alt,
              color: Colors.grey[850],
            ),
            onPressed: updatePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: titleController, // 컨트롤러를 연결
                decoration: const InputDecoration(
                  hintText: '제목',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromRGBO(79, 111, 82, 1.0)), // 원하는 색상으로 설정
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: descriptionController, // 컨트롤러를 연결
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
}
