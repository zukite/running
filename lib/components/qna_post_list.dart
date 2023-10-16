import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:running/components/qna_post_tile.dart';
import 'package:running/pages/qna_detail_page.dart';

class QnaPostList extends StatelessWidget {
  const QnaPostList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("QnAPosts")
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('작성된 게시글이 없습니다.'),
          );
        } else {
          final qnaPosts = snapshot.data!.docs;

          return ListView.builder(
              itemCount: qnaPosts.length,
              itemBuilder: (context, index) {
                final qnaPost = qnaPosts[index].data() as Map<String, dynamic>;
                final timestamp = qnaPost['timestamp'];
                if (timestamp != null && timestamp is Timestamp) {
                  return GestureDetector(
                    child: QnaPostTile(
                      title: qnaPost["title"],
                      subtitle: qnaPost["desc"],
                      timestamp: qnaPost['timestamp'],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => QnaDetail(
                          postData: qnaPost,
                        ),
                      ));
                    },
                  );
                } else {
                  return Container();
                }
              });
        }
      },
    );
  }
}
