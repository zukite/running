import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

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
          title: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // 양 끝에 배치하려면 MainAxisAlignment 설정
            children: [
              Text(
                comment.text,
                textAlign: TextAlign.left,
              ),
              OutlinedButton(
                onPressed: () {},
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.all(0)), // 내용 주위의 간격 설정
                  minimumSize:
                      MaterialStateProperty.all(Size(45, 25)), // 버튼의 최소 크기 설정
                  side: MaterialStateProperty.all(BorderSide(
                    width: 1, // 아웃라인의 크기 설정
                    color: Colors.grey, // 아웃라인 색상 설정
                  )),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey[400], // 원하는 색상으로 변경
                  size: 15, // 원하는 크기로 변경),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              Text(comment.text),
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
