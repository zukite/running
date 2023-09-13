// import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:running/components/button.dart';
import 'package:running/components/text_field.dart';
// import 'package:running/pages/login_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  // 로그인 함수
  void signIn() async {
    // 진행중이라는 것을 나타내는 대기원
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 로그인 시도
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // 로딩 원 종료
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop 로딩 원
      Navigator.pop(context);
      // 화면에 에러메시지 나타냄
      displayMEssage(e.code);
    }
  }

  // 오류메세지 보여주는 함수
  void displayMEssage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

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
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: emailTextController,
                    hintText: "이메일 입력",
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: passwordTextController,
                    hintText: "비밀번호 입력",
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  MyButton(onTap: signIn, text: "로그인"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "회원이 아니신가요?",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "회원가입",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
