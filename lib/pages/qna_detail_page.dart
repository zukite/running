import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/comment_list.dart';
import 'package:running/components/text_field.dart';
import 'package:running/pages/qna_edit_page.dart';

import '../utils/comment.dart';

class QnaDetail extends StatefulWidget {
  final Map<String, dynamic> postData;
  final User? currentUser; // 현재 사용자 정보

  const QnaDetail({
    Key? key, // key를 직접 정의해야 합니다.
    required this.postData,
    required this.currentUser,
  });

  @override
  State<QnaDetail> createState() => _QnaDetailState();
}

class _QnaDetailState extends State<QnaDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final textController = TextEditingController();

  void deletePost() async {
    if (widget.currentUser != null &&
        widget.currentUser!.uid == widget.postData['authorUid']) {
      try {
        // 게시물을 Firestore에서 삭제
        await _firestore
            .collection('QnAPosts')
            .doc(widget.postData['key'])
            .delete();

        // 게시물을 삭제한 후 현재 페이지를 닫음
        Navigator.pop(context);
      } catch (e) {
        // 삭제 중에 오류가 발생한 경우 오류 처리
        print('게시물 삭제 오류: $e');
      }
    }
  }

  void postComment() async {
    String commentText = textController.text;
    // 사용자 이름을 getUsername 함수를 사용하여 가져오기
    String userName = await getUsername(widget.currentUser!.uid);

    if (commentText.isNotEmpty) {
      Comment comment = Comment(
        authorId: widget.currentUser!.uid, // 현재 사용자의 UID
        authorName: userName,
        text: commentText,
        timestamp: Timestamp.now(),
      );

      // Firestore에 댓글 저장
      await _firestore
          .collection('QnAPosts')
          .doc(widget.postData['key'])
          .collection('comments')
          .add({
        'authorId': comment.authorId,
        'authorName': comment.authorName,
        'text': comment.text,
        'timestamp': comment.timestamp,
      });

      // 댓글 작성 후 텍스트 필드를 지웁니다.
      textController.clear();
    }
  }

  Future<String> getUsername(String userId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.email)
            .get();
        if (userDoc.exists) {
          return userDoc['username'];
        }
      }
      return '';
    } catch (e) {
      print('사용자 정보 가져오기 오류: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = widget.currentUser?.uid == widget.postData['authorUid'];
    final isCurrentUserAuthor = isAuthor;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "질문 게시판",
          style: TextStyle(color: Colors.grey[850]),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[850]),
        actions: [
          IconButton(
            onPressed: () {
              if (isCurrentUserAuthor) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QnaEdit(
                      documentId: widget.postData['key'],
                      initialTitle: widget.postData['title'],
                      initialDescription: widget.postData['desc'],
                    ),
                  ),
                );
              } else {
                // 현재 사용자가 게시글 작성자가 아닌 경우 알림 띄우기
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("작성자가 아닙니다."),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.edit,
              color: Colors.grey[800],
            ),
          ),
          IconButton(
            onPressed: () {
              // 현재 사용자와 게시글 작성자를 비교하여 동일한 경우에만 삭제 작업 수행
              if (isCurrentUserAuthor) {
                // 게시물을 삭제하는 함수 호출
                deletePost();
              } else {
                // 현재 사용자가 게시글 작성자가 아닌 경우 알림 띄우기
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("작성자가 아닙니다."),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.delete,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.postData['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            widget.postData['desc'],
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 0.8, // 테두리의 높이
                            color: Colors.grey[350], // 테두리의 색상
                          ),
                        ],
                      ),
                    ),
                    CommentList(postKey: widget.postData['key']),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 5, 15, 10),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: "댓글을 입력하세요",
                    obscureText: false,
                  ),
                ),
                IconButton(
                  onPressed: postComment,
                  icon: const Icon(Icons.arrow_circle_up),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
