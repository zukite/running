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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.postData['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      widget.postData['desc'],
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 0.8, // 테두리의 높이
                      color: Colors.grey[350], // 테두리의 색상
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
