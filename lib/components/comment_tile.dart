import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final String postKey; // 게시물의 키
  final String commentId; // 댓글의 고유 ID
  final User? currentUser; // 현재 사용자 정보

  const CommentTile({
    super.key,
    required this.comment,
    required this.postKey,
    required this.commentId,
    required this.currentUser,
  });

  void deleteComment() async {
    if (currentUser != null && currentUser!.uid == comment.authorId) {
      try {
        // 게시물의 댓글 컬렉션에서 해당 댓글 문서의 참조를 얻습니다.
        final commentRef = FirebaseFirestore.instance
            .collection('QnAPosts')
            .doc(postKey)
            .collection('comments')
            .doc(commentId); // 댓글의 document ID를 얻는 방법

        // 댓글 문서를 삭제합니다.
        await commentRef.delete();
        print(commentRef);
      } catch (e) {
        print('댓글 삭제 중 오류 발생: $e');
      }
    } else {
      print("실패");
    }
  }

  void editComment(BuildContext context) {
    if (currentUser != null && currentUser!.uid == comment.authorId) {
      final TextEditingController textEditingController =
          TextEditingController(text: comment.text);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("댓글 수정"),
            content: TextField(
              controller: textEditingController,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // 수정한 내용을 Firestore에 업데이트
                  FirebaseFirestore.instance
                      .collection('QnAPosts')
                      .doc(postKey)
                      .collection('comments')
                      .doc(commentId)
                      .update({'text': textEditingController.text});
                  Navigator.pop(context);
                },
                child: Text("수정"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("취소"),
              ),
            ],
          );
        },
      );
    } else {
      print("실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Timestamp를 DateTime으로 변환
    final dateTime = comment.timestamp.toDate();

    // DateTime을 특정 형식으로 포맷
    final formattedTimestamp = DateFormat('MM/dd  hh:mm').format(dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      child: Card(
        color: Colors.grey[50],
        elevation: 0.7, // 그림자 제거
        child: ListTile(
          title: Text(
            comment.text,
            textAlign: TextAlign.left,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              const SizedBox(height: 10),
              Text(comment.authorName ?? "Unknown Author"),
              Row(
                children: [
                  Text(
                    formattedTimestamp,
                    style: const TextStyle(
                      fontSize: 12, // timestamp의 글꼴 크기 조정
                      color: Colors.grey, // timestamp의 글꼴 색상 설정
                    ),
                  ),
                  const Spacer(), // 아이콘 버튼을 오른쪽으로 밀어 줍니다.
                  IconButton(
                    onPressed: () {
                      editComment(context);
                    },
                    icon: const Icon(Icons.edit),
                    padding: const EdgeInsets.all(0), // 모든 패딩 제거
                    alignment: Alignment.center, // 아이콘을 텍스트와 정확하게 정렬
                    constraints: const BoxConstraints(), // 아이콘 크기에 대한 제약 없음
                    iconSize: 15,
                  ),
                  const SizedBox(width: 8), // 아이콘 사이에 약간의 여백 추가
                  IconButton(
                    onPressed: () {
                      deleteComment();
                    },
                    icon: const Icon(Icons.delete),
                    padding: const EdgeInsets.all(0), // 모든 패딩 제거
                    alignment: Alignment.center, // 아이콘을 텍스트와 정확하게 정렬
                    constraints: const BoxConstraints(), // 아이콘 크기에 대한 제약 없음
                    iconSize: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
