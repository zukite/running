import 'package:flutter/material.dart';
// import 'package:running/pages/post_detail_page.dart';

class MyPostTile extends StatelessWidget {
  final String title;
  // final String subtitle;
  final String image;

  const MyPostTile({
    Key? key,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: Image.network(
                image,
                fit: BoxFit.cover, // 이미지를 꽉 채우도록 설정
                width: 50, // 이미지의 가로 크기를 조절 (원의 반경과 동일하게)
                height: 50, // 이미지의 세로 크기를 조절 (원의 반경과 동일하게)
              ),
            ), // 이미지를 동적으로 로드
          ),
          title: Text(title),
        ),
      ),
    );
  }
}
