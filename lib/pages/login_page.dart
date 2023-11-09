import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/button.dart';
import 'package:running/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({
    Key? key,
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

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // 로딩 원 종료
      if (mounted) {
        Navigator.pop(context);
      }

      if (userCredential != null) {
        // 로그인 성공한 경우
        // ...
      }
    } on FirebaseAuthException catch (e) {
      // pop 로딩 원
      if (context != null) {
        Navigator.pop(context);
      }
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고
                  const Icon(
                    Icons.directions_run,
                    size: 100.0,
                  ),
                  const SizedBox(height: 15),

                  // 앱 이름
                  const Text(
                    "같이 뛸래?",
                    style: TextStyle(fontSize: 30),
                  ),
                  // const Text(
                  //   "CREW",
                  //   style: TextStyle(fontSize: 30),
                  // ),
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
