import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/post_tile.dart';
import 'package:running/pages/post_detail_page.dart';

class MyProfilePostList extends StatelessWidget {
  const MyProfilePostList({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
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

          final filteredPosts = posts.where((post) {
            final authorUid = post['authorUid'];
            return authorUid == currentUser?.uid; // 현재 사용자의 UID와 일치하는 게시글만 반환
          }).toList();

          return ListView.builder(
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index].data() as Map<String, dynamic>;
              final imageUrl = post['imageUrl'];
              final timestamp = post['timestamp'];

              if (timestamp != null && timestamp is Timestamp) {
                return GestureDetector(
                  child: MyPostTile(
                    title: post['crewName'],
                    timestamp: post['timestamp'],
                    image: imageUrl,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostDetail(
                        postData: post,
                        currentUser: currentUser,
                      ),
                    ));
                  },
                );
              } else {
                return Container();
              }
            },
          );
        }
      },
    );
  }
}
