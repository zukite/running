import 'package:flutter/material.dart';
import 'package:running/components/qna_post_list.dart';
import 'package:running/pages/qna_add_page.dart';
import 'package:running/pages/qna_search_page.dart';

class QnAPage extends StatefulWidget {
  const QnAPage({super.key});

  @override
  State<QnAPage> createState() => _QnAPageState();
}

class _QnAPageState extends State<QnAPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
        iconTheme: IconThemeData(color: Colors.grey[850]),
        title: Text(
          "질문 게시판",
          style: TextStyle(color: Colors.grey[850]),
        ),
        elevation: 0.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const qnaSearch()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddQna()),
              );
            },
          ),
        ],
      ),
      body: const QnaPostList(), // QnaPostList 위젯을 추가
    );
  }
}
