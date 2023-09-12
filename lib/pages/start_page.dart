import 'package:flutter/material.dart';
// import 'package:running/pages/login_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 130),

              // 로고
              const Icon(
                Icons.directions_run,
                size: 100.0,
              ),
              const SizedBox(height: 15),

              // 앱 이름
              const Text(
                "RUNNING",
                style: TextStyle(fontSize: 30),
              ),
              const Text(
                "CREW",
                style: TextStyle(fontSize: 30),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: Text("이메일로 시작하기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
