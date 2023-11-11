import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:running/auth/auth.dart';
import 'package:running/firebase_options.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 앱 초기화 작업을 수행하는 Future
  late final Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    // 앱 초기화를 시작
    _initialization = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 1.5초 후에 AuthPage로 이동
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 여기에 원하는 UI 구성 요소들을 추가
            Image.asset(
              'assets/logo.jpg',
              width: MediaQuery.of(context).size.width,
            ),
          ],
        ),
      ),
    );
  }
}
