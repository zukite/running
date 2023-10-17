import 'package:flutter/material.dart';

class EditPost extends StatelessWidget {
  final Map<String, dynamic> postData;

  EditPost({
    Key? key,
    required this.postData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // EditPost 페이지의 내용을 구현하세요.
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: Center(
        child: Text('This is the Edit Post page for ${postData['crewName']}'),
      ),
    );
  }
}
