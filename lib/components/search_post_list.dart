import 'package:flutter/material.dart';
import 'package:running/components/post_tile.dart';
import 'package:running/pages/post_detail_page.dart';

class SearchPostList extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  const SearchPostList({
    super.key,
    required this.searchResults,
  });

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
                  ), // 클릭된 포스트 정보 전달
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
