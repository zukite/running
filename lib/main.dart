import 'package:flutter/material.dart';
import 'package:running/auth/login_or_register.dart';
// import 'package:running/pages/login_page.dart';
// import 'package:running/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(useMaterial3: true),
      // initialRoute: '/start',
      home: LoginOrRegister(),
      // home: const StartPage(),
    );
  }
}
