import 'package:flutter/material.dart';

class MyPostTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const MyPostTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(image), // 외부에서 받아온 이미지 URL 사용
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          onTap: () {},
        ),
      ),
    );
  }
}
