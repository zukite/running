import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/auth/login_or_register.dart';
import 'package:running/pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 로그인이 된다면 홈페이지로 이동
        if (snapshot.hasData) {
          return const MyHomePage();

          // 로그인 되지 않는다면 로그인 또는 회원가입 페이지로 이동
        } else {
          return const LoginOrRegister();
        }
      },
    ));
  }
}
