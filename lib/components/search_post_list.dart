import 'package:flutter/material.dart';
import 'package:running/components/post_tile.dart';

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
          return MyPostTile(
            title: result['crewName'],
            timestamp: result['timestamp'],
            image: result['imageUrl'],
          );
        },
      );
    }
  }
}
