import 'package:flutter/material.dart';
import 'package:running/pages/login_page.dart';
import 'package:running/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // 초기에 (처음) 보이는 로그인 화면 보여주기
  bool showLoginPage = true;

// 로그인페이지와 회원가입페이지 사이를 전환하는 토글 메소드
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로그인페이지 표시가 true인지 확인
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}
