import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/qna_search_list.dart';

class qnaSearch extends StatefulWidget {
  const qnaSearch({super.key});

  @override
  State<qnaSearch> createState() => _qnaSearchState();
}

class _qnaSearchState extends State<qnaSearch> {
  final TextEditingController _searchController =
      TextEditingController(); // 검색어를 입력하고 검색버튼을 누를 때 검색어를 가져오기 위한 컨트롤러
  List<Map<String, dynamic>> searchResults =
      []; // Firestore에서 검색 쿼리를 실행하고 결과를 가져오는 함수

// Firestore에서 검색 쿼리를 실행하고 결과를 가져오는 함수
  void _searchPosts(String query) async {
    setState(() {
      searchResults = []; // 검색 결과 초기화
    });

    if (query.length >= 2) {
      List<String> keywords = query.split(" ");

      Query queryRef = FirebaseFirestore.instance.collection("QnAPosts");

      for (String keyword in keywords) {
        queryRef = queryRef
            .where("title", isGreaterThanOrEqualTo: keyword)
            .where("title", isLessThanOrEqualTo: keyword + '\uf8ff');
      }

      queryRef.get().then((querySnapshot) {
        setState(() {
          searchResults.addAll(querySnapshot.docs
              .map((doc) => doc.data())
              .cast<Map<String, dynamic>>()
              .toList());
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 238, 234, 1.0),
        iconTheme: IconThemeData(
          color: Colors.grey[850],
        ),
        title: Text(
          "질문 게시글 검색",
          style: TextStyle(
            color: Colors.grey[850],
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '글 제목, 내용',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(79, 111, 82, 1.0)),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(79, 111, 82, 1.0)),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                fillColor: Colors.grey[300],
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    _searchPosts(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: SearchQnAList(
              searchResults: searchResults,
              currentUser: FirebaseAuth.instance.currentUser, // 현재 사용자 정보를 전달
            ),
          ),
        ],
      ),
    );
  }
}
