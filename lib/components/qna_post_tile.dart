import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QnaPostTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Timestamp timestamp;

  const QnaPostTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Timestamp를 DateTime으로 변환
    final dateTime = timestamp.toDate();

    // DateTime을 특정 형식으로 포맷
    final formattedTimestamp = DateFormat('MM/dd').format(dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Card(
        color: Colors.grey[50],
        elevation: 0, // 그림자 제거
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0), // 아래 테두리만 설정
          ),
          side: BorderSide(
            color: Colors.grey, // 테두리 색상 설정
            width: 1, // 테두리 두께 설정
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8), // 내용 패딩 조정
          title: Text(
            title,
            textAlign: TextAlign.left, // Text 정렬 왼쪽으로 설정
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              Text(subtitle),
              Text(
                formattedTimestamp,
                style: TextStyle(
                  fontSize: 12, // timestamp의 글꼴 크기 조정
                  color: Colors.grey, // timestamp의 글꼴 색상 설정
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
