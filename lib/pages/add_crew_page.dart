import 'package:flutter/material.dart';

class MyAddCrew extends StatefulWidget {
  const MyAddCrew({super.key});

  @override
  State<MyAddCrew> createState() => _MyAddCrewState();
}

class _MyAddCrewState extends State<MyAddCrew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("크루 개설"),
      ),
    );
  }
}
