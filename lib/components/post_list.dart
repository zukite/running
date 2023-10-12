import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:running/components/post_tile.dart';
import 'package:running/pages/post_detail_page.dart';

class MyPostList extends StatelessWidget {
  const MyPostList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Posts")
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
          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              final imageUrl = post['imageUrl']; // 이미지 URL 가져오기
              return GestureDetector(
                child: MyPostTile(
                  title: post['crewName'],
                  // subtitle: post['explain'],
                  image: imageUrl, // 이미지 URL 전달
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostDetail(
                      postData: post,
                    ),
                  ));
                },
              );
            },
          );
        }
      },
    );
  }
}
