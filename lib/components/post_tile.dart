import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:running/pages/post_detail_page.dart';

class MyPostTile extends StatelessWidget {
  final String title;
  final Timestamp timestamp;
  final String image;

  const MyPostTile({
    Key? key,
    required this.title,
    required this.image,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Timestamp를 DateTime으로 변환
    final dateTime = timestamp.toDate();

    // DateTime을 특정 형식으로 포맷
    final formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: Image.network(
                image,
                fit: BoxFit.cover, // 이미지를 꽉 채우도록 설정
                width: 50, // 이미지의 가로 크기를 조절 (원의 반경과 동일하게)
                height: 50, // 이미지의 세로 크기를 조절 (원의 반경과 동일하게)
              ),
            ), // 이미지를 동적으로 로드
          ),
          title: Text(title),
          subtitle: Text(formattedTimestamp),
        ),
      ),
    );
  }
}
