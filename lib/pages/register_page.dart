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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
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
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordTextController,
                  hintText: "비밀번호 입력",
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: "비밀번호 확인",
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                MyButton(onTap: () {}, text: "회원가입"),
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
    );
  }
}
