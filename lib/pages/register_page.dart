import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/button.dart';
import 'package:running/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // 회원 등록 함수
  void signUp() async {
    // 대기중 순환 원 보여줌
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (!emailTextController.text.contains("@")) {
      // pop 순환원
      Navigator.pop(context);

      // 사용자에게 에러메시지 보여줌
      displayMessage("이메일 주소를 정확하게 입력해주세요");
      return;
    } else if (passwordTextController.text.length < 6) {
      // pop 순환원
      Navigator.pop(context);

      // show error to user
      displayMessage("비밀번호는 6자 이상 입력해주세요");
      return;
    } else if (passwordTextController.text !=
        confirmPasswordTextController.text) {
      // pop loding circle
      Navigator.pop(context);
      // show error to user
      displayMessage("비밀번호가 일치하지않습니다");
      return;
    }

    // try creating the user
    try {
      // 사용자 생성
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      //     // 사용자 생성 후,  파이어베이스에 새 문서를 만들고 이를 사용자라고 칭함
      FirebaseFirestore.instance
          .collection("User")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split("@")[0],
        'userregion': ' ' // initially empty bio
        // add any additional fields as needed
      });

      // pop loding circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loding circle
      Navigator.pop(context);
      //show error to user
      displayMessage(e.code);
    }
  }

  // display a dialog message
  void displayMessage(String message) {
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
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                    width: MediaQuery.of(context).size.width / 3 * 2,
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
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: "비밀번호 확인",
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  MyButton(onTap: signUp, text: "회원가입"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "이미 회원이십니까?",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "로그인",
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(79, 111, 82, 1.0),
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
