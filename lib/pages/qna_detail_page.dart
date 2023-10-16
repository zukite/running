import 'package:flutter/material.dart';

class QnaDetail extends StatefulWidget {
  final Map<String, dynamic> postData;
  const QnaDetail({
    super.key,
    required this.postData,
  });

  @override
  State<QnaDetail> createState() => _QnaDetailState();
}

class _QnaDetailState extends State<QnaDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "질문 게시판",
          style: TextStyle(color: Colors.grey[850]),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[850]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                child: Row(children: []),
              )
            ],
          ),
        ),
      ),
    );
  }
}
