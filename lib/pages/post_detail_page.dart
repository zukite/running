import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/pages/post_edit_page.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';

class PostDetail extends StatefulWidget {
  final Map<String, dynamic> postData;
  final User? currentUser; // 현재 사용자 정보

  const PostDetail({
    Key? key, // key를 직접 정의해야 합니다.
    required this.postData,
    required this.currentUser,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void deletePost() async {
    if (widget.currentUser != null &&
        widget.currentUser!.uid == widget.postData['authorUid']) {
      try {
        // 게시물을 Firestore에서 삭제
        await _firestore
            .collection('Posts')
            .doc(widget.postData['key'])
            .delete();

        // 게시물을 삭제한 후 현재 페이지를 닫음
        Navigator.pop(context);
      } catch (e) {
        // 삭제 중에 오류가 발생한 경우 오류 처리
        print('게시물 삭제 오류: $e');
      }
    }
  }

  Future<void> _launchURL() async {
    Uri url = Uri.parse(widget.postData['kakaoUrl']);
    try {
      if (!await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw '실행할 수 없습니다';
      }
    } catch (e) {
      print('URL 열기 오류 : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = widget.currentUser?.uid == widget.postData['authorUid'];
    final isCurrentUserAuthor = isAuthor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.postData['crewName'],
          style: TextStyle(
            color: Colors.grey[850],
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[850]),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.star_border_rounded),
            color: Colors.grey[850],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (isCurrentUserAuthor) {
                if (value == '수정하기') {
                  // Navigate to the edit post page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPost(postData: widget.postData),
                    ),
                  );
                } else if (value == '삭제하기') {
                  // 게시물 삭제 함수 호출
                  deletePost();
                }
              } else {
                // Display a message if the current user is not the author
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("게시글의 작성자가 아닙니다"),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              final items = <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: '수정하기',
                  child: Text('수정하기'),
                ),
              ];

              if (isCurrentUserAuthor) {
                // Only show the "삭제하기" option if the current user is the author
                items.add(
                  const PopupMenuItem<String>(
                    value: '삭제하기',
                    child: Text('삭제하기'),
                  ),
                );
              }

              return items;
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    widget.postData['imageUrl'],
                    fit: BoxFit.fill,
                  ),
                ),
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          widget.postData['crewName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          widget.postData['explain'],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _launchURL,
          // onPressed: () {},
          child: Text("가입하기"),
          style: ElevatedButton.styleFrom(
              elevation: 0, textStyle: TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}
