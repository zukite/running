import 'package:flutter/material.dart';

class MyProfileModify extends StatefulWidget {
  const MyProfileModify({super.key});

  @override
  State<MyProfileModify> createState() => _MyProfileModifyState();
}

class _MyProfileModifyState extends State<MyProfileModify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(
          color: Colors.grey[850],
        ),
        title: Text("프로필 수정"),
      ),
    );
  }
}
