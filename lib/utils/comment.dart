import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String authorId; // 댓글 작성자의 고유 ID
  final String text; // 댓글 내용
  final Timestamp timestamp; // 댓글 작성 시간

  Comment(
      {required this.authorId, required this.text, required this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      authorId: data['authorId'],
      text: data['text'],
      timestamp: data['timestamp'],
    );
  }
}
