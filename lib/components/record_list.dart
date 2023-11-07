import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/record_tile.dart';

class MyRecordList extends StatefulWidget {
  final User currentUser;
  const MyRecordList({
    super.key,
    required this.currentUser,
  });

  @override
  State<MyRecordList> createState() => _MyRecordListState();
}

class _MyRecordListState extends State<MyRecordList> {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("RecordTime")
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('달린 기록이 없습니다.'),
          );
        } else {
          final posts = snapshot.data!.docs;

          final filteredPosts = posts.where((post) {
            final authorUid = post['authorUid'];
            return authorUid == currentUser?.uid; // 현재 사용자의 UID와 일치하는 게시글만 반환
          }).toList();

          return Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post =
                    filteredPosts[index].data() as Map<String, dynamic>;
                final timestamp = post['timestamp'];

                if (timestamp != null && timestamp is Timestamp) {
                  return MyRecordTile(
                    recordTime: post['recordTime'],
                    timeStamp: timestamp,
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        }
      },
    );
  }
}
