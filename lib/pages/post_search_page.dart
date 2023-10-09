import 'package:flutter/material.dart';

class PostSearch extends StatefulWidget {
  const PostSearch({super.key});

  @override
  State<PostSearch> createState() => _PostSearchState();
}

class _PostSearchState extends State<PostSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(
          color: Colors.grey[850],
        ),
        title: Text(
          "게시글 검색",
          style: TextStyle(
            color: Colors.grey[850],
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(),
    );
  }
}
