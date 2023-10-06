import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String crewName;
  final String explain;
  final String num;
  final String region;
  final String kakaoUrl;

  const PostCard({
    super.key,
    required this.crewName,
    required this.explain,
    required this.num,
    required this.region,
    required this.kakaoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return const Card();
  }
}
