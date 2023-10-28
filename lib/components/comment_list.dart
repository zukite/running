import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:running/components/comment_tile.dart';
import '../utils/comment.dart';

class CommentList extends StatelessWidget {
  final String postKey; // 게시물의 고유 키

  CommentList({
    required this.postKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('QnAPosts')
          .doc(postKey) // 게시물의 키로 문서에 접근
          .collection('comments')
          .orderBy('timestamp', descending: false) // timestamp를 오름차순으로 정렬
          .snapshots(), // 게시물의 댓글 데이터 가져오기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(''),
          );
        } else {
          final comments = snapshot.data!.docs;
          return Column(
            children: comments
                .map(
                  (commentDoc) => CommentTile(
                    comment: Comment.fromDocument(commentDoc),
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }
}
