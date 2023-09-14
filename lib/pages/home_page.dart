import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/drawer.dart';
import 'package:running/pages/add_crew_page.dart';
// import 'package:running/components/navigation.dart';
import 'package:running/pages/profile_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isClick = true; // 클릭했을 때 색상 변경위한 변수

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyProfilePage(),
      ),
    );
  }

  void goToAddCrewPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyAddCrew(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "신사동",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[850]),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.3,
          ),
        ),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isClick = true;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        "모집 중인 크루",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isClick ? Colors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2.0,
                        width: 197.7,
                        color: isClick ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isClick = false;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        "추천 크루",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: !isClick ? Colors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2.0,
                        width: 197.7,
                        color: !isClick ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 게시글 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // pop menu drawer
          Navigator.pop(context);

          // go to profile page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyProfilePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
