import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running/components/post_tile.dart';
import 'package:running/pages/post_detail_page.dart';

class SearchPostList extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final User? currentUser; // currentUser를 생성자에서 받도록 수정

  const SearchPostList({
    Key? key,
    required this.searchResults,
    required this.currentUser, // currentUser를 생성자에서 받도록 수정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.'),
      );
    } else {
      return ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return GestureDetector(
            onTap: () {
              // 클릭 시 상세 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetail(
                    postData: result,
                    currentUser: currentUser, // 수정된 currentUser를 전달
                  ),
                ),
              );
            },
            child: MyPostTile(
              title: result['crewName'],
              timestamp: result['timestamp'],
              image: result['imageUrl'],
            ),
          );
        },
      );
    }
  }
}
