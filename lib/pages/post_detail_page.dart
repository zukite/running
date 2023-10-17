import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/pages/edit_post_page.dart';
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
  // // 함수를 만들어 URL을 여는 데 사용할 것입니다.
  // _launchURL() async {
  //   final String url = widget.postData['kakaoUrl'];
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isAuthor = widget.currentUser?.uid == widget.postData['authorUid'];

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
            icon: Icon(Icons.star_border_rounded),
            color: Colors.grey[850],
          ),
          if (isAuthor) // 작성자인 경우에만 수정 버튼을 표시
            IconButton(
              onPressed: () {
                // 게시글 수정 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPost(postData: widget.postData),
                  ),
                );
              },
              icon: Icon(Icons.edit),
              color: Colors.grey[850],
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
          // onPressed: _launchURL,
          onPressed: () {},
          child: Text("가입하기"),
          style: ElevatedButton.styleFrom(
              elevation: 0, textStyle: TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}
