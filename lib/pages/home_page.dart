import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/drawer.dart';
import 'package:running/components/post_list.dart';
import 'package:running/pages/add_crew_page.dart';
import 'package:running/pages/post_search_page.dart';
import 'package:running/pages/profile_page.dart';
import 'package:running/pages/qna_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
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

  void qnaPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QnAPage(),
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
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("User")
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                userData['userregion'],
                style: TextStyle(color: Colors.grey[850]),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[850]),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PostSearch()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
        onQnA: qnaPage,
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
                        width: MediaQuery.of(context).size.width / 2 - 8,
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
                        width: MediaQuery.of(context).size.width / 2 - 8,
                        color: !isClick ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isClick)
            const Expanded(
              child: MyPostList(), // 모집 중인 크루를 선택한 경우 MyPostList 표시
            ),
        ],
      ),

      // 게시글 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MyAddCrew()),
          );
        },
        elevation: 0.0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
